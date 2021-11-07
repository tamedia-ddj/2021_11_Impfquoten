library(tidyverse)
library(readxl)


WORKING_DIR<- "path_to_working_dir"
setwd(WORKING_DIR)
getwd()


## PLZ Lookup up to date
in_PLZ2 <- read_delim("PLZ Lookup/CH37.csv", delim = ";")
lkp_PLZ2 <- in_PLZ2 %>%
  # filter(EDID == 0) %>% # Nur Gebäude statt Adressen berücksichtigen?
  group_by(GDENR, GDENAME, DPLZ4, GDEKT) %>% 
  summarise(n_build = n()) %>% 
  group_by(DPLZ4) %>%
  mutate(proc_von_PLZ = n_build / sum(n_build)) %>% 
  group_by(GDENR) %>% 
  mutate(proc_von_gem = n_build / sum(n_build)) %>% 
  rename(c("plz" = "DPLZ4")) %>% 
  mutate(plz = as.character(plz))

## Population Lookup
# Just neede for additional Info in map
lkp_pop <- read_delim("Data_input/municipality_population.csv", delim = ";") %>% 
  mutate(GDENR = as.numeric(GDENR))

## VD Vaccination Data ####
# per 01.01.2021: Aubonne und Montherod zur Gemeinde Aubonne zusammengeschlossen.
# per 01.07.2021: Apples, Bussy-Chardonney, Cottens, Pampigny, Reverolle und Sévery zur Gemeinde Hautemorges zusammengeschlossen.
# per 01.07.2021: Assens und Bioley-Orjulaz zur Gemeinde Assens zusammengeschlossen.
in_VD <- read_xlsx("Data_input/Statistiques personnes vaccinées par NPA - VAUD OFS.xlsx") %>% 
  rename(c("plz" = "NPA", "municip_est" = "Estimation ville", "canton_est" = "Estimation du canton",
           "ncumul_firstvacc" = "Personnes vaccinées", "population" = "Population STAT VD")) %>% 
  mutate(ncumul_secondvacc = 0,
         week_until = lubridate::as_date("2021-09-01"),
         plz = as.character(plz))
  
## Add Population and PLZ-Lookup
df_VD <- in_VD %>%
  left_join(lkp_PLZ2[, c("plz", "proc_von_PLZ", "proc_von_gem", "GDENR", "GDENAME", "GDEKT")], by = "plz") %>% 
  mutate(
    vac1_von_gem = ncumul_firstvacc * proc_von_gem,
    vac2_von_gem = ncumul_secondvacc * proc_von_gem,
    vac1_von_plz = ncumul_firstvacc * proc_von_PLZ,
    vac2_von_plz = ncumul_secondvacc * proc_von_PLZ,
    pop_von_plz = population * proc_von_PLZ)

# test <- in_VD %>%
#   full_join(lkp_PLZ2[lkp_PLZ2$GDEKT == "VD" , c("plz", "proc_von_PLZ", "proc_von_gem", "GDENR", "GDENAME", "GDEKT")], by = "plz") %>% 
#   mutate(
#     vac1_von_gem = ncumul_firstvacc * proc_von_gem,
#     vac2_von_gem = ncumul_secondvacc * proc_von_gem,
#     vac1_von_plz = ncumul_firstvacc * proc_von_PLZ,
#     vac2_von_plz = ncumul_secondvacc * proc_von_PLZ,
#     pop_von_plz = population * proc_von_PLZ)


df_VD_mun <- df_VD %>%
  group_by(GDENR, GDENAME, GDEKT, week_until) %>%
  summarise(
    n_vac1 = sum(vac1_von_plz),
    n_vac2  = sum(vac2_von_plz),
    pop = sum(pop_von_plz),
    PLZ_procs = list(proc_von_gem), 
    check_proc_gem = sum(proc_von_gem),
    PLZs = list(plz)) %>% 
  mutate(
    proc_vac1 = n_vac1/pop,
    proc_vac2 = n_vac2/pop) %>% 
  filter(GDEKT == "VD") %>% 
  left_join(lkp_pop[, c("GDENR", "pop_gde_bfs")])

## ZH Vaccination Data ####
# weekly updated
download.file("https://raw.githubusercontent.com/openZH/covid_19_vaccination_campaign_ZH/master/COVID19_Impfungen_pro_Woche_PLZ.csv",
              "Data_input/ZH_PLZ_vaccination.csv")

in_ZH_raw <- read_csv("https://raw.githubusercontent.com/openZH/covid_19_vaccination_campaign_ZH/master/COVID19_Impfungen_pro_Woche_PLZ.csv") %>% 
  filter(!plz %in% c("andere Kantone", "Nachbarkantone", "unbekannt"))
min(in_ZH$week_until)

in_ZH <- in_ZH_raw
# Vaccination Numbers get distributed to municipalities via the PLZ-municipality table (lkp_plz) from BFS.
# This table shows the percentage of buildings in a municipality that are part of a PLZ.
# The distribution of population (from BFS) in the same way is assumed.
# So proc_plz_gde means the percentage of buildings in a certain PLZ that are part of a ceratain municipality.
# This ratio is used to distribute the vaccination counts of a certain PLZ to different municipalities.
# Also the given "population" per PLZ from the "in_ZH" data is distributed to the municipalities this way.
# This will lead to slightly different numbers then shown in official BFS population data. ("pop_bfs")


## Add Population and PLZ-Lookup
df_ZH <- in_ZH_raw %>%
  left_join(lkp_PLZ2[, c("plz", "proc_von_PLZ", "proc_von_gem", "GDENR", "GDENAME", "GDEKT")], by = "plz") %>% 
  mutate(
         vac1_von_gem = ncumul_firstvacc * proc_von_gem,
         vac2_von_gem = ncumul_secondvacc * proc_von_gem,
         vac1_von_plz = ncumul_firstvacc * proc_von_PLZ,
         vac2_von_plz = ncumul_secondvacc * proc_von_PLZ,
         pop_von_plz = population * proc_von_PLZ)

df_ZH_mun <- df_ZH %>%
  group_by(GDENR, GDENAME, GDEKT, week_until) %>%
  summarise(
            n_vac1 = sum(vac1_von_plz),
            n_vac2  = sum(vac2_von_plz),
            pop = sum(pop_von_plz),
            PLZ_procs = list(proc_von_gem), 
            check_proc_gem = sum(proc_von_gem),
            PLZs = list(plz)) %>% 
  mutate(
         proc_vac1 = n_vac1/pop,
         proc_vac2 = n_vac2/pop) %>% 
  filter(GDEKT == "ZH")

  # left_join(lkp_pop[, c("GDENR", "pop_gde_bfs")])
  
## Ausserkantonal: People being vaccinated outside of the canton of ZH are not registered with their PLZ

# PLZ gibt den Wohnort der Geimpften an, ausser: "andere Kantone"	, "Nachbarkantone", "ZH aber ausserkantonal geimpft", "unbekannt"
# "von Menschen mit Wohnsitz im Kanton ZH, die ausserkantonal geimpft wurden, sind keine Wohnsitzinformationen nach Bezirken vorhanden"
# Ausserkantonal geimpfte werden anteilsmässig den Gemeinden zugerechnet
# (gewichtet mit der Impquote pro Gemeinde)
  
n_ausserkant1 <- df_ZH[df_ZH$plz == "ZH aber ausserkantonal geimpft", "ncumul_firstvacc"][[1]]
n_ausserkant2 <- df_ZH[df_ZH$plz == "ZH aber ausserkantonal geimpft", "ncumul_secondvacc"][[1]]
proc_ausserkant1 <- n_ausserkant1 / sum(df_ZH_mun$pop)
proc_ausserkant2 <- n_ausserkant2 / sum(df_ZH_mun$pop)

mean_vac1 <- weighted.mean(df_ZH_mun$proc_vac1, df_ZH_mun$pop)
mean_vac2 <- weighted.mean(df_ZH_mun$proc_vac2, df_ZH_mun$pop)

df_ZH_mun_total <- df_ZH_mun %>% 
  mutate(proc_vac1_ausserkant = proc_ausserkant1 / mean_vac1 * proc_vac1,
         proc_vac2_ausserkant = proc_ausserkant2 / mean_vac2 * proc_vac2,
         proc_vac1_total =  proc_vac1 + proc_vac1_ausserkant,
         proc_vac2_total = proc_vac2 + proc_vac2_ausserkant)

df_ZH_mun_total_last <- df_ZH_mun_total %>% 
  filter(week_until == max(week_until))


## export ####
# Full Data
df_ZH_mun_total_last %>% write_csv("Data_output/vacc_ZH_full.csv")
df_VD_mun %>% write_csv("Data/vacc_VD_full.csv")


# For Datawrapper
# Achtung, es werden die Werte OHNE die ausserkantonal geimpften exportiert!!
df_ZH_mun_total_last %>% 
  select(c(GDENR, GDENAME, GDEKT, week_until, n_vac1, n_vac2, 
           proc_vac1, proc_vac2)) %>% 
  write_csv("Data/dw_vacc_ZH.csv")

df_VD_mun %>% 
  select(c(GDENR, GDENAME, GDEKT, week_until, n_vac1, n_vac2, 
           proc_vac1, proc_vac2)) %>% 
  write_csv("Data/dw_vacc_VD.csv")


## Verlauf ####
df_ZH_sum <- df_ZH_mun %>%
  group_by(week_until) %>% 
  summarise(n_vac1 = sum(n_vac1),
            n_vac2 = sum(n_vac2),
            pop = sum(pop)) %>% 
  mutate(proc_vac1 = n_vac1 / pop,
         proc_vac2 = n_vac2 / pop,
         GDENAME = "Durchschnitt") %>% 
  bind_rows(df_ZH_mun[c("GDENAME", "week_until", "n_vac1", "n_vac2", "pop", "proc_vac1", "proc_vac2")])


df_ZH_sum %>% filter(GDENAME %in% c("Ellikon an der Thur", "Durchschnitt")) %>% 
  ggplot(aes(x = week_until, y = proc_vac1,
             group = GDENAME, color = GDENAME, label = week_until)) +
  geom_line() + 
  scale_x_date(date_breaks = "1 week", date_labels =  "%d %b") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


