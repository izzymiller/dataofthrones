## Modeling the **#DataofThrones**
###### Izzy Miller
#
#

#### *Data Acquisition*
When we had the idea to run the Data of Thrones campaign, we kinda just decided to go for it without a whole lot of scoping. We set up a marketing plan, timelines, blog post themes, formats, etc... And then realized we probably had to get some data to analyze. 

When we ran the previous campaign, in 2017, we used 3 datasets: A [simple screentime dataset](https://data.world/aendrew/game-of-thrones-screen-times) and a [deaths dataset](https://www.kaggle.com/mylesoneill/game-of-thrones) were the TV-based tables, and they got joined into a fact table based on information from the books about battles and such.

This year, we had the dream of opening everything up to the public to explore, so we wanted to provide a somewhat richer dataset— Purely in the interests of keeping our users from getting bored :P. To that end, I collected a whole bunch of datasets. I downloaded the same screentime dataset as last year, updated to include season 7, and joined it up with the AMAZING datasets that Jeffrey Lancaster created [here](https://github.com/jeffreylancaster/game-of-thrones). I tossed out some of the data in that repo that was related to network visualizations and relationships, but kept most of the information about characters and scenes— Those two json files made up the bulk of the explorable data.

The JSON's were pretty deeply nested. Using pandas (specifically, json_normalize, kinda similar to this tutorial:https://www.kaggle.com/jboysen/quick-tutorial-flatten-nested-json-in-pandas), I was able to unnest and smush all of the scene actions and character info into just a couple of tables: `episodes`,`characters`,`scenes`,`locations`, and `opening_locations`.

That gave us most of the data we'd need— The one thing missing was script information. For this, I turned to [genius](https://genius.com/Game-of-thrones-beyond-the-wall-script-annotated) which has crowdsourced script data on every episode. The formatting isn't perfect, but it was decent enough to work with as a starting point. I used the [lyricsgenius package](https://github.com/johnwmillr/LyricsGenius) because I'm lazy. 

I saved a CSV of all the episode names, and then set lyricsgenius loose on it:
```
import lyricsgenius
import json
import pandas as pd

#instantiate genius API
genius = lyricsgenius.Genius("APIKEY")

#load in episodes
episodes = pd.read_csv("~/got/dot_episodes_list.csv")
episodes = episodes.values.tolist()


#scrape the episodes scripts
for ep in episodes:
	song = genius.search_song(ep[0], "Game Of Thrones") #I added Game Of Thrones here so as to not get extraneous songs in my results
	song.save_lyrics()
```

This worked pretty well. I had to do a few manual changes and fill in a couple gaps, but it saved a lot of time. Now I had a giant json blob for each episode that just had a raw text field of the entire script, and that simply wouldn't do. 
```
for filename in os.listdir('/Users/izzymiller/Desktop/gotscripts'):
	if filename.endswith(".json"):
		start = pd.read_json(filename)
		episode = start['songs'][0]['title']
		script =  start['songs'][0]['lyrics'].splitlines()
		z = []
		for i in script:
			if ":" in i:
				z.append(i)
			elif not i:
				pass
			else: 
				up = "SCENEDIR: {} ".format(i)
				z.append(up)

		sp = []
		for i in z:
			sp.append(i.split(':')[0])

		df = pd.DataFrame({'speaker':sp})

		sp = []
		for i in z:
			sp.append(i.split(':')[1])

		df['line'] = sp
		df.to_csv('~/Desktop/cleanscripts/{}-formatted.csv'.format(episode))
	else:
		continue
```
I split out each line into its own row in a CSV, and parsed out the speaker of each line. Most lines followed the format `SPEAKER: LINE`, so capturing everything before the `:` worked for getting the speaker. If there was no `:`, I assumed it was a scene direction (of which there were many) and applied the `SCENEDIR` speaker. After dumping each script to it's own CSV, uploading the dataset to BigQuery and doing a tiny bit of manual cleanup (mostly changing a few characters names in bulk to match the data from Jeffrey Lancaster), I was good to go.

But I felt like there was still some information to be had out of these scripts that we couldn't get in this format (at least not easily, with SQL.). I grabbed those script files, now all neatly indexed by speaker and line, and pushed them through [VADER](https://github.com/cjhutto/vaderSentiment), the *Valence Aware Dictionary and sEntiment Reasoner*.
```
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
analyser = SentimentIntensityAnalyzer()
def sentiment_analyzer_scores(line):
    score = analyser.polarity_scores(line)
    return score
```
By this point, my script table was already 100% complete— It contained information about episode, speaker, line ID, etc, so I could just push the entire thing through VADER all at once. I threw my script table into pandas as a dataframe, and then 
```
neg = []
pos = []
neu = []
overall = []
for line in scripts:
    score = sentiment_analyzer_scores(line)
    neg.append(score['neg'])
    neu.append(score['neu'])
    pos.append(score['pos'])
    overall.append(score['compound'])
```
and plopped those values out into their own dataframes, which I could then easily merge into the existing dataframe with ID, speaker, episode, and so on. Back into BigQuery, and I had my line-by-line sentiment data. 

There were a few more manual pieces. We went through and wrote down every non-human character and manually created a `species` column, and we changed some names manually so that we could join tables together :
```
UPDATE  `lookerdata.game_of_thrones_19.script_by_word` SET scripts_unnested_speaker = 'LITTLEFINGER' WHERE scripts_unnested_speaker = 'PETYR BAELISH'
```

After that, it was time to hit the LookML!

#### *Building some gross Derived Tables*
I'm not the best Looker analyst (I'm just a friendly neighborhood community manager!), so take all of this with a grain of salt. Some parts of the model/views are downright hacky, and lots of it is slow. I had some help from Maire Newton on a lot of this, too, who is a much more level-headed LookML developer than me!

I wound up making a character_facts table, since pulling a lot of character information from scene-level data wasn't great. 
```
view: character_facts {
  derived_table: {
    sql: WITH scene_screentime AS (
    SELECT
  characters.characterName  AS character_name,
  COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE((TIME_DIFF( scenes.scene_end,scenes.scene_start,second)) ,0)*(1/1000*1.0), 9) AS NUMERIC) + (cast(cast(concat('0x', substr(to_hex(md5(CAST(concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST(concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) AS FLOAT64), 0), 6), 0) AS scene_length
FROM game_of_thrones_19.episodes  AS episodes
LEFT JOIN game_of_thrones_19.scenes  AS scenes ON (CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))) = (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string)))
LEFT JOIN game_of_thrones_19.scenes  AS scene_characters ON (concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))) = (concat((CONCAT(CAST(scene_characters.season_num AS string), "-",CAST(scene_characters.episode_num AS string))),"-", (CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string)))))
LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = scene_characters.characters_name

GROUP BY 1

),
deaths AS (
      SELECT
        scene_characters.characters_name  AS characters_name,
        scene_characters.characters_manner_of_death  AS scene_characters_characters_manner_of_death,
        scene_characters.characters_alive  AS scene_characters_characters_alive,
        STRING_AGG(scene_characters.characters_manner_of_death) OVER (PARTITION BY scene_characters.characters_name) AS character_death,
        STRING_AGG(CAST(scene_characters.characters_alive AS STRING)) OVER (PARTITION BY scene_characters.characters_name) AS character_is_alive

      FROM game_of_thrones_19.episodes  AS episodes
      LEFT JOIN game_of_thrones_19.scenes  AS scenes ON (CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))) = (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string)))
      LEFT JOIN game_of_thrones_19.scenes  AS scene_characters ON (concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))) = (concat((CONCAT(CAST(scene_characters.season_num AS string), "-",CAST(scene_characters.episode_num AS string))),"-", (CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string)))))

      GROUP BY 1,2,3
      ORDER BY 1),
kills AS (
WITH deaths AS (SELECT
  death_episode.character_name  AS character_name,
  death_episode.killed_by  AS death_episode_killed_by
FROM game_of_thrones_19.episodes  AS episodes
LEFT JOIN ${death_episode.SQL_TABLE_NAME} AS death_episode ON (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string))) = death_episode.unique_episode

GROUP BY 1,2
ORDER BY 1 )
SELECT killers.characterName as killer_name,
COUNT(DISTINCT deaths.character_name) AS count_kills
FROM game_of_thrones_19.characters killers
LEFT JOIN deaths ON killers.characterName = deaths.death_episode_killed_by
GROUP BY 1
)

      SELECT
       deaths.characters_name
      ,deaths.character_death
      ,CASE WHEN deaths.character_is_alive IS NULL THEN 'Yes' ELSE 'No' END as character_is_alive
      ,characters.id
      ,characters.actorLink
      ,characters.actorName
      ,characters.characterimageFull
      ,characters.characterImageThumb
      ,SPLIT(UPPER(characters.characterName),' ')[SAFE_OFFSET(0)] AS firstname
      ,characters.characterLink
      ,characters.species
      ,CASE WHEN gender.gender = "male" THEN "Male" WHEN gender.gender = "female" THEN "Female" END AS gender
      ,kills.count_kills
      ,scene_screentime.scene_length AS screentime
      ,CASE
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Frey') THEN 'Frey'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Greyjoy') THEN 'Greyjoy'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Targaryen') THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Lannister') THEN 'Lannister'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Baratheon') THEN 'Baratheon'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Ironborn') THEN 'Greyjoy'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Khal') THEN 'Dothraki'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Dothraki') THEN 'Dothraki'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Tyrell') THEN 'Tyrell'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Watchman') THEN 'Nights Watch'
      ELSE houses.string_field_1 END AS character_house
      ,row_number() OVER() AS key
      FROM deaths
      LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = deaths.characters_name
      LEFT JOIN game_of_thrones_19.characters_houses AS houses ON deaths.characters_name = houses.string_field_0
      LEFT JOIN game_of_thrones_19.char_gender AS gender ON gender.character_name = characters.characterName
      LEFT JOIN scene_screentime ON scene_screentime.character_name = characters.characterName
      LEFT JOIN kills ON kills.killer_name = characters.characterName
      WHERE deaths.characters_name IS NOT NULL
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13,14,15
      ORDER BY 1
 ;;

sql_trigger_value: 1 ;;
  }

  dimension: id {
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    label: " ⁣Name"
    description: "Character Name"
    type: string
    sql: ${TABLE}.characters_name  ;;
  }
  dimension: firstname {
    type: string
    hidden: yes
    #for joining
    sql: ${TABLE}.firstname ;;
  }

  dimension: species {
    description: "Species of Character, assumed to be human if not clear."
    type: string
    sql: CASE WHEN ${TABLE}.species IS NULL THEN 'Human' ELSE ${TABLE}.species END ;;
  }

  dimension: death {
    description: "Manner of Death. Null if alive."
    type: string
    sql: ${TABLE}.character_death ;;
  }

  dimension: is_alive {
    description: "Is the character alive?"
    type: yesno
    sql: CASE WHEN ${TABLE}.character_is_alive = 'Yes' THEN TRUE
              WHEN ${TABLE}.characters_name = 'Jon Snow' THEN TRUE
              ELSE FALSE END;;
  }

  dimension: gender {
    type: string
    label: "Gender"
    description: "Gender of Character. Only populated for main characters!"
    sql: COALESCE(${TABLE}.gender,"Unspecified") ;;
  }

  dimension: has_killed {
    description: "Has the character killed anyone?"
    type: yesno
    sql: ${TABLE}.count_kills > 0 ;;
  }

  dimension: actor_link {
    hidden: yes
    type: string
    sql: ${TABLE}.actorLink ;;
  }

  dimension: actor_name {
    description: "Name of primary actor"
    type: string
    sql: ${TABLE}.actorName ;;
  }

  dimension: image_full {
    label: "Full Image"
    group_label: "Images"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterimageFull ;;
  }

  dimension: image_thumb {
    label: "Thumbnail Image"
    group_label: "Images"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterImageThumb ;;
  }

  dimension: character_link {
    hidden: yes
    description: "This links out to IMDb but I can't figure out exactly how to format the URL."
    type: string
    sql: ${TABLE}.characterLink ;;
  }

  dimension: house_derived {
    hidden: yes
    type: string
    sql:
      CASE
        WHEN ${name} = 'Jorah Mormont' THEN 'Mormont'
        WHEN ${name} = 'Samwell Tarly' THEN 'Tarly'
        WHEN ${name} = 'Brienne of Tarth' THEN 'Tarth'
        WHEN ${name} = 'Davos Seaworth' THEN 'Seaworth'
        WHEN ${name} = 'Petyr Baelish' THEN 'Baelish'
        WHEN ${name} = 'Sandor Clegane' THEN 'Clegane'
        WHEN ${name} = 'Barristan Selmy' THEN 'Selmy'
        WHEN ${name} = 'Ramsay Snow' THEN 'Bolton'
        WHEN ${name} = 'Gendry' THEN 'Baratheon'
        WHEN ${name} = 'Gregor Clegane' THEN 'Clegane'
        WHEN ${name} = 'Meera Reed' THEN 'Reed'
        WHEN ${name} = 'Roose Bolton' THEN 'Bolton'
        WHEN ${name} = 'Randyll Tarly' THEN 'Tarly'
        WHEN ${name} = 'Dickon Tarly' THEN 'Tarly'
      ELSE ${TABLE}.character_house
      END ;;
  }

  dimension: house {
    description: "Characters House. None if unclear."
    type: string
    sql:
      CASE
        WHEN TRIM(${house_derived}) = 'Include' THEN 'None'
        WHEN TRIM(${house_derived}) IS NULL THEN 'None'
      ELSE ${house_derived}
      END ;;
  }

  dimension: current_alliance {
    description: "Group currently allied with"
    type: string
    sql:
      CASE
        WHEN REGEXP_CONTAINS(${name}, 'Targaryen') THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(${name}, 'Dothraki') THEN 'Targaryen'
        WHEN ${name} = 'Tyrion Lannister' THEN 'Targaryen'
        WHEN ${name} = 'Jorah Mormont' THEN 'Targaryen'
        WHEN ${name} = 'Lord Varys' THEN 'Targaryen'
        WHEN ${name} = 'Sandor Clegane' THEN 'Targaryen'
        WHEN ${name} = 'Missandei' THEN 'Targaryen'
        WHEN ${name} = 'Grey Worm' THEN 'Targaryen'
        WHEN ${name} = 'Drogon' THEN 'Targaryen'
        WHEN ${name} = 'Qhono' THEN 'Targaryen'
        WHEN ${name} = 'Unsullied' THEN 'Targaryen'
        WHEN ${name} = 'Illyrio Mopatis' THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(${name}, 'Martell') THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(${name}, 'Sand') THEN 'Targaryen'
        WHEN ${name} = 'Aeron Greyjoy' THEN 'Lannister'
        WHEN REGEXP_CONTAINS(${name}, 'Greyjoy') THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(${name}, 'Lannister') THEN 'Lannister'
        WHEN REGEXP_CONTAINS(${name}, 'Frey') THEN 'Lannister'
        WHEN REGEXP_CONTAINS(${name}, 'Ironborn') THEN 'Lannister'
        WHEN ${name} = 'Bronn' THEN 'Lannister'
        WHEN ${name} = 'Gregor Clegane' THEN 'Lannister'
        WHEN ${name} = 'Qyburn' THEN 'Lannister'
        WHEN ${name} = 'Ilyn Payne' THEN 'Lannister'
        WHEN ${name} = 'Samwell Tarly' THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Tarly') THEN 'Lannister'
        WHEN REGEXP_CONTAINS(${name}, 'Stark') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Mormont') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Umber') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Tully') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Karstark') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Reed') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Watch') THEN 'Stark'
        WHEN ${name} = 'Jon Snow' THEN 'Stark'
        WHEN ${name} = 'Ghost' THEN 'Stark'
        WHEN ${name} = 'Davos Seaworth' THEN 'Stark'
        WHEN ${name} = 'Tormund Giantsbane' THEN 'Stark'
        WHEN ${name} = 'Yohn Royce' THEN 'Stark'
        WHEN ${name} = 'Robin Arryn' THEN 'Stark'
        WHEN ${name} = 'Brienne of Tarth' THEN 'Stark'
        WHEN ${name} = 'Podrick Payne' THEN 'Stark'
        WHEN ${name} = 'Eddison Tollett' THEN 'Stark'
        WHEN ${name} = 'Gendry' THEN 'Stark'
        WHEN ${name} = 'Gilly' THEN 'Stark'
        WHEN ${name} = 'Robett Glover' THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Wight') THEN 'White Walkers'
        WHEN ${name} = 'The Night King' THEN 'White Walkers'
        WHEN ${name} = 'Rhaegal' THEN 'White Walkers'


      ELSE 'None'
      END ;;
  }

  dimension: key {
    type: number
    sql: ${TABLE}.key ;;
    hidden: yes
    primary_key: yes
  }


  measure: count {
    label: "Number of Characters"
    type: count
    drill_fields: [detail*]
  }

  measure: count_house {
    label: "Number of Houses"
    type: count_distinct
    sql: ${house} ;;
    drill_fields: [detail*]
  }

  measure: kills {
    description: "Number of named kills made"
    type: sum
    sql: ${TABLE}.count_kills ;;
#     drill_fields: [death_episode.character_name,death_episode.manner_of_death,death_episode.unique_episode]
  }

   measure: total_screentime {
     hidden: no
     label: "Total Screentime"
     description: "Pre-Aggregated. Not as good as the other ones"
     type: sum
     sql: ${TABLE}.screentime ;;
   }

  measure: screentime_seconds {
    group_label:"Screentime"
    label: "Screentime (Seconds)"
    description: "Total length in seconds of scenes including Character.
    Not just their moments on screen, so slightly inflated from their genuine, precise, screen time"
    type: sum_distinct
    sql_distinct_key: ${scenes.unique_scene} ;;
    sql: ${scenes.scene_length_secs} ;;
    drill_fields: [detail*]
  }

  measure: screentime_minutes {
    group_label:"Screentime"
    label: "Screentime (Minutes)"
    description: "Total length in Minutes of scenes including Character.
    Not just their moments on screen, so slightly inflated from their genuine, precise, screen time"
    type: sum_distinct
    sql_distinct_key: ${scenes.unique_scene} ;;
    sql: ${scenes.scene_length_secs}/60 ;;
    value_format_name: decimal_0
    drill_fields: [detail*]
  }
  ````


This is probably the best part of the entire model:
```
  dimension: is_alive {
    description: "Is the character alive?"
    type: yesno
    sql: CASE WHEN ${TABLE}.character_is_alive = 'Yes' THEN TRUE
              WHEN ${TABLE}.characters_name = 'Jon Snow' THEN TRUE
              ELSE FALSE END;;
  }
  ```
  
  That table gives us fact information about each character, and serves as the base of any character explores. The general characters view is still joined in as it has a few missing pieces, but it's pretty plain vanilla, and almost every field is hidden in favor of character_facts:
  ```
  view: characters {
  sql_table_name: game_of_thrones_19.characters ;;

  dimension: abducted {
    group_label: "Relationships"
    hidden: yes
    #Hiding this because literally only 1 person was abducted and it clutters the explore needlessly
    type: string
    sql: ${TABLE}.abducted ;;
  }

  dimension: abducted_by {
    group_label: "Relationships"
    hidden: yes
    #Hiding this because literally only 1 person was abducted and it clutters the explore needlessly
    type: string
    sql: ${TABLE}.abductedBy ;;
  }

  dimension: actor_link {
    #IMDB actor link. Could join in other stuff from imdb dataset
    type: string
    sql: ${TABLE}.actorLink ;;
    hidden: yes
  }

  dimension: actor_name {
    hidden: yes
    #Does not contain everything
    #hidden in favor of character_facts
    type: string
    sql: ${TABLE}.actorName ;;
  }

  dimension: actors {
    #hidden in favor of character_facts
    hidden: yes
    type: string
    sql: ${TABLE}.actors ;;
  }

  dimension: allies {
    group_label: "Relationships"
    description: "Individual Characters— Not necessarily on a House basis. "
    type: string
    sql: ${TABLE}.allies ;;
  }

  dimension: character_image_full {
    hidden: yes
    #hidden in favor of character_facts
    group_label: "Images"
    label: "Full"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterImageFull ;;
  }

  dimension: character_image_thumb {
    hidden: yes
    #hidden in favor of character_facts
    group_label: "Images"
    label: "Thumbnail"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterImageThumb ;;
  }

  dimension: character_link {
    #hidden in favor of character_facts
    #IMDB char link
    hidden: yes
    type: string
    sql: ${TABLE}.characterLink ;;
  }

  dimension: character_name {
    #hidden in favor of character_facts
    hidden: yes
    type: string
    sql: ${TABLE}.characterName ;;
  }

  dimension: guarded_by {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.guardedBy ;;
  }

  dimension: guardian_of {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.guardianOf ;;
  }

  dimension: house_name {
    #hidden in favor of character_facts, which is more comprehensive.
    hidden: yes
    type: string
    sql: ${TABLE}.houseName ;;
  }

  dimension: int64_field_0 {
    #id
    hidden: yes
    type: number
    sql: ${TABLE}.int64_field_0 ;;
  }

  dimension: killed {
    group_label: "Relationships"
    #covered elsewhere
    hidden: yes
    type: string
    sql: ${TABLE}.killed ;;
  }

  dimension: killed_by {
    group_label: "Relationships"
    #covered elsewhere
    hidden: yes
    type: string
    sql: ${TABLE}.killedBy ;;
  }

  dimension: kingsguard {
    description: "Is Character Kings Guard?"
    type: yesno
    sql: ${TABLE}.kingsguard ;;
  }

  dimension: married_engaged {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.marriedEngaged ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}.nickname ;;
  }

  dimension: parent_of {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.parentOf ;;
  }

  dimension: parents {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.parents ;;
  }

  dimension: royal {
    type: yesno
    sql: ${TABLE}.royal ;;
  }

  dimension: served_by {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.servedBy ;;
  }

  dimension: serves {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.serves ;;
  }

  dimension: sibling {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.sibling ;;
  }

  dimension: siblings {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.siblings ;;
  }

  measure: count {
    hidden: yes
    type: count_distinct
    sql: ${character_name} ;;
  }
}
```

You might have noticed that `character_facts` references another derived table called `death_episode`. There's two purpose-built PDT's (sex_episode and death_episode) that just return data on who died and who had sex in each episode. They're almost identical, other than referencing different activities.
```
view: death_episode {
  derived_table: {
    sql: SELECT
  CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string))  AS unique_episode,
  characters.characterName  AS character_name,
  scene_characters.characters_killed_by  AS killed_by,
  scene_characters.characters_manner_of_death  AS manner_of_death,
  CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string))  AS scene_id
FROM game_of_thrones_19.episodes  AS episodes
LEFT JOIN game_of_thrones_19.scenes  AS scenes ON (CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))) = (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string)))
LEFT JOIN game_of_thrones_19.scenes  AS scene_characters ON (concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))) = (concat((CONCAT(CAST(scene_characters.season_num AS string), "-",CAST(scene_characters.episode_num AS string))),"-", (CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string)))))
LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = scene_characters.characters_name

WHERE
  ((scene_characters.characters_manner_of_death IS NOT NULL))
GROUP BY 1,2,3,4,5
 ;;
sql_trigger_value: SELECT 1 ;;
  }

  dimension: pk {
    type: string
    hidden: yes
    sql: CONCAT(COALESCE(${unique_episode},'blank'),COALESCE(${character_name},'blank'),COALESCE(${killed_by},'blank'),COALESCE(${manner_of_death},'blank'),COALESCE(${scene_id},'blank')) ;;
    primary_key: yes
  }

  dimension: unique_death {
    type: string
    hidden: yes
    sql: CONCAT(COALESCE(${unique_episode},'blank'),COALESCE(${character_name},'blank'),COALESCE(${manner_of_death},'blank'),COALESCE(${scene_id},'blank')) ;;
  }

  dimension: unique_episode {
    hidden: yes
    type: string
    sql: ${TABLE}.unique_episode ;;
  }

  dimension: character_name {
    hidden: yes
    type: string
    sql: ${TABLE}.character_name ;;
  }

  dimension: killed_by {
    type: string
    sql: ${TABLE}.killed_by ;;
  }

  dimension: scene_id {
    hidden: yes
    type: string
    sql: ${TABLE}.scene_id ;;
  }

  dimension: manner_of_death {
    description: "How character died. Null if alive."
    type: string
    sql: ${TABLE}.manner_of_death ;;
  }


  measure: count_named_deaths {
    type: count_distinct
    description: "Number of deaths of named characters. Does not include unnamed deaths."
    label: "Number of Named Deaths"
    sql: ${unique_death} ;;
    filters: {
      field: character_name
      value: "-NULL"
    }
    drill_fields: [detail*]
  }

  measure: count_kills {
    hidden: yes
    type: count_distinct
    label: "Number of Kills"
    description: "Number of named kills. Does not include unnamed kills"
    sql: CASE WHEN ${killed_by} = ${character_name} THEN ${pk} ELSE NULL END ;;
  }

  set: detail {
    fields: [unique_episode,scene_id,character_name,killed_by,manner_of_death]
  }

}
```
And:
```
view: sex_episode {
  derived_table: {
    sql: SELECT
  CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string))  AS unique_episode,
  characters.characterName  AS character_name,
  scene_characters.characters_sex_with  AS sex_with,
  CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))  AS scene_id,
  scene_characters.characters_sex_type  AS sex_type,
  scene_characters.characters_sex_when  AS sex_when
FROM game_of_thrones_19.episodes  AS episodes
LEFT JOIN game_of_thrones_19.scenes  AS scenes ON (CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))) = (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string)))
LEFT JOIN game_of_thrones_19.scenes  AS scene_characters ON (concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))) = (concat((CONCAT(CAST(scene_characters.season_num AS string), "-",CAST(scene_characters.episode_num AS string))),"-", (CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string)))))
LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = scene_characters.characters_name

WHERE
  ((scene_characters.characters_sex_with IS NOT NULL))
GROUP BY 1,2,3,4,5,6
 ;;
sql_trigger_value: SELECT 1 ;;
  }

  dimension: pk {
    type: string
    hidden: yes
    sql: concat(${unique_episode},${character_name},${sex_with},${scene_id}) ;;
    primary_key: yes
  }

  dimension: unique_episode {
    label: "Unique Episode"
    description: "Season/Episode combination"
    type: string
    sql: ${TABLE}.unique_episode ;;
  }

  dimension: character_name {
    hidden: no
    type: string
    sql: ${TABLE}.character_name ;;
  }

  dimension: sex_with {
    description: "Character name who the sex was with"
    type: string
    sql: ${TABLE}.sex_with ;;
  }

  dimension: sex_type {
    description: "Type of Sex"
    type: string
    sql: ${TABLE}.sex_type ;;
  }

  dimension: sex_when {
    description: "Time-frame in which the sex took place. Not 100% sure about this field!"
    type: string
    sql: ${TABLE}.sex_when ;;
  }

  dimension: scene_id {
    hidden: yes
    type: string
    sql: ${TABLE}.scene_id ;;
  }

  measure: count_sex {
    type: count_distinct
    sql: ${pk} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [unique_episode,scene_id,character_name,sex_with,sex_type]
  }


}
````
  
Scripts was simple and "Generate View from Table" sufficed to bring in every relevant dimension, I think. I converted the scores into measures so we could aggregate them across speaker, episode, etc. 
```
view: scripts {
  sql_table_name: game_of_thrones_19.lines ;;


  dimension: id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }


#   dimension: unique_line_id {
#     primary_key: yes
#     type: string
#     sql: concat(${episode},CAST(${linenum} AS STRING)) ;;
#   }


  dimension: episode {
    hidden: yes
    label: "Episode"
    description: "Episode Title"
    type: string
    sql: ${TABLE}.episode ;;
  }

  dimension: linenum {
    label: "Line Number"
    description: "The number of the line within the episode, chronologically"
    #The number of the line within the episode-- Ordering.
    type: number
    sql: ${TABLE}.linenum ;;
  }

  dimension: line {
    label: "Line"
    description: "Actual words spoken"
    type: string
    sql: ${TABLE}.line ;;
  }

  dimension: speaker_raw {
    #Character Name. SCENEDIR for scene direction lines.
    hidden: yes
    type: string
    sql:
        ${TABLE}.speaker;;
  }

  dimension: speaker {
    description: "Character Name who Spoke. 'SCENEDIR' for scene directions"
    type: string
    sql: ${TABLE}.speaker ;;
  }


  ##SENTIMENT ANALYSIS, DONE USING VADER

  dimension: sentiment {
    description: "Sentiment of line, calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: number
    sql: ${TABLE}.compound ;;
  }

  measure: average_sentiment {
    label: "Average Sentiment of lines"
    description: "Sentiment calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: average
    sql: ${sentiment} ;;
    drill_fields: [detail*]
  }

  measure: count_negative_lines {
    label: "Number of Negative Lines"
    description: "Sentiment calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: count
    filters: {
      field: sentiment
      value: "<0"
    }
    drill_fields: [detail*]
  }
  measure: count_positive_lines {
    label: "Number of Positive lines"
    description: "Sentiment calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: count
    filters: {
      field: sentiment
      value: ">0"
    }
    drill_fields: [detail*]
  }

  measure: count_neutral_lines {
    label: "Number of Neutral Lines"
    description: "Sentiment calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: count
    filters: {
      field: sentiment
      value: "0"
    }
    drill_fields: [detail*]
  }

  measure: count {
    label: "Count of all lines"
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [episode,linenum,line,speaker,sentiment]
  }

}
```

Getting the script information *line by line* was a bit interesting. I wanted this pretty badly, so I could see who used which words and build word clouds & distributions. I ended up ditching the derived table approach for this and making it a real table, but the SQL I used to create it is:
```
WITH scripts_unnested AS (WITH agg AS (SELECT
      scripts.speaker  AS scripts_speaker,
      scripts.episode AS episode,
      split(REPLACE(REPLACE(LOWER(REGEXP_REPLACE(line, r'[\.\",*:()\[\]/|\n]', ' ')),'!',''),'?',''),' ') AS word
    FROM `game_of_thrones_19.lines`  AS scripts
    WHERE scripts.speaker != 'SCENEDIR'

    )

    SELECT scripts_speaker, episode, a, GENERATE_UUID() AS id
    FROM agg
    CROSS JOIN UNNEST(agg.word) AS a )
SELECT 
	scripts_unnested.id  AS scripts_unnested_pk,
	scripts_unnested.episode  AS scripts_unnested_episode,
	CASE WHEN scripts_unnested.a IN ('the','to','a','and','of','is','i','that','in','it','i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', 'your', 'yours', 'yourself', 'yourselves', 'he', 'him', 'his', 'himself', 'she', 'her', 'hers', 'herself', 'it', 'its', 'itself', 'they', 'them', 'their', 'theirs', 'themselves', 'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'am', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 'does', 'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while', 'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into', 'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down', 'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very', 's', 't', 'can', 'will', 'just', 'don', 'should', 'now')  THEN 'Yes' ELSE 'No' END
 AS scripts_unnested_is_stopword,
	SPLIT((CASE
          WHEN TRIM(scripts_unnested.scripts_speaker) = 'SANDOR' THEN 'HOUND'
          WHEN TRIM(scripts_unnested.scripts_speaker) = 'BAELISH' THEN 'LITTLEFINGER'
          WHEN TRIM(UPPER(scripts_unnested.scripts_speaker)) = 'PETYR BAELISH' THEN 'LITTLEFINGER'
        ELSE UPPER(TRIM(scripts_unnested.scripts_speaker))
        END), ' ')[SAFE_OFFSET(0)]  AS scripts_unnested_speaker,
	scripts_unnested.a  AS scripts_unnested_word
FROM `game_of_thrones_19.lines`  AS scripts
LEFT JOIN scripts_unnested ON scripts.episode = scripts_unnested.episode AND (SPLIT((CASE
          WHEN TRIM(scripts.speaker) = 'SANDOR' THEN 'HOUND'
          WHEN TRIM(scripts.speaker) = 'BAELISH' THEN 'LITTLEFINGER'
          WHEN TRIM(UPPER(scripts.speaker)) = 'PETYR BAELISH' THEN 'LITTLEFINGER'
        ELSE UPPER(TRIM(scripts.speaker))
        END), ' ')[SAFE_OFFSET(0)]) = (SPLIT((CASE
          WHEN TRIM(scripts_unnested.scripts_speaker) = 'SANDOR' THEN 'HOUND'
          WHEN TRIM(scripts_unnested.scripts_speaker) = 'BAELISH' THEN 'LITTLEFINGER'
          WHEN TRIM(UPPER(scripts_unnested.scripts_speaker)) = 'PETYR BAELISH' THEN 'LITTLEFINGER'
        ELSE UPPER(TRIM(scripts_unnested.scripts_speaker))
        END), ' ')[SAFE_OFFSET(0)]) 

GROUP BY 1,2,3,4,5
ORDER BY 1
```
I unnested scripts, added some stopword logic for labelling and filtering purposes, and built in some character name replacement logic into the query so that wouldn't have to execute at runtime. It used to be just a normal DT, and the queries would regularly hit the 60 minute timeout :(.

Episodes is pretty simple, aside from some compound Primary Key generation

```
view: episodes {
  sql_table_name: game_of_thrones_19.episodes ;;

  dimension: pk {
    type: string
    sql: CONCAT(CAST(${season_num} AS string),"-",CAST(${episode_num} AS string),"-",${opening_sequence_locations}) ;;
    primary_key: yes
    hidden: yes
  }

  dimension: unique_episode {
    type: string
    sql: CONCAT(CAST(${season_num} AS string),"-",CAST(${episode_num} AS string)) ;;
  }

  dimension: episode_num {
    label: "Episode"
    type: number
    sql: ${TABLE}.episode_num ;;
  }

  dimension: air_date {
    description: "Original Air Date of Episode"
    type: string
    sql: ${TABLE}.air_date ;;
  }

  dimension: description {
    description: "Episode Description"
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: link {
    description: "IMDb Link to Episode"
    type: string
    html: <a href="https://www.imdb.com/{{value}}" ;;
    sql: ${TABLE}.link ;;
  }

  dimension: opening_sequence_locations {
    description: "Locations seen in the opening title animation."
    type: string
    sql: ${TABLE}.opening_sequence_locations ;;
    map_layer_name: major_locations
  }

  dimension: season_num {
    label: "Season"
    type: number
    sql: ${TABLE}.season_num ;;
  }

  dimension: title {
    description: "Title of Episode"
    type: string
    sql: ${TABLE}.title ;;
  }

  measure: count_episodes {
    label: "Number of Episodes"
    type: count_distinct
    sql: ${unique_episode} ;;
    drill_fields: [detail*]
  }

  measure: scene_length {
    label: "Runtime (m)"
    description: "Total length of episode in minutes. Same as Screentime, but not tied to Character/Scene"
    type: sum_distinct
    sql_distinct_key: ${scenes.unique_scene} ;;
    sql: ${scenes.scene_length_secs}/60 ;;
  }


  set: detail {
    fields: [season_num,episode_num,title,description]
  }
}
```

Scenes is also fairly basic, with some measures added in to calculate screentime.
```
view: scenes {
  sql_table_name: game_of_thrones_19.scenes ;;

  dimension: pk {
    #Generated Row_Number over the entire dataset, means nothing but uniqueness
    type: number
    sql: ${TABLE}.pk ;;
    hidden: yes
    primary_key: yes
  }

  dimension: unique_scene {
    type: string
    sql: concat(${unique_ep},"-", ${scene_id}) ;;
    primary_key: no
  }

  dimension: scene_id {
    description: "ID of Scene within the episode. In chronological order"
    ##The ID of the scene within the episode
    type: string
    sql: CONCAT(CAST(${TABLE}.scene_start AS string), '-', CAST(${TABLE}.scene_end AS string)) ;;
  }

  dimension: unique_ep {
    label: "Unique Episode"
    description: "Season/Episode combination"
#     hidden: yes
    ## The Season/Episode Number combo
    type: string
    sql: CONCAT(CAST(${season_num} AS string), "-",CAST(${episode_num} AS string)) ;;
  }

  dimension: season_num {
    label: "Season"
#     hidden: yes
    type: number
    sql: ${TABLE}.season_num ;;
  }

  dimension: episode_num {
    label: "Episode"
#     hidden: yes
    type: number
    sql: ${TABLE}.episode_num ;;
  }

  # dimension: alt_location {
  #   group_label: "Location"
  #   label: "Alternate Location"
  #   type: string
  #   sql: ${TABLE}.alt_location ;;
  # }

  dimension: flashback {
    label: "Is Flashback?"
    type: string
    sql: ${TABLE}.flashback ;;
  }

  dimension: greensight {
    label: "Has Greensight?"
    type: string
    sql: ${TABLE}.greensight ;;
  }

  dimension: location {
    group_label: "Location"
    label: "Location"
    type: string
    sql: ${TABLE}.location ;;
#     map_layer_name: major_locations
  }

  dimension: scene_end {
    label: "Scene End Time"
    description: "Timestamp in Episode that scene ended"
    type: string
    sql: ${TABLE}.scene_end ;;
  }

  dimension: scene_start {
    label: "Scene Start Time"
    description: "Timestamp in Episode that scene began"
    type: string
    sql: ${TABLE}.scene_start ;;
  }

  dimension: scene_length_secs {
    type: number
    hidden: yes
    sql: TIME_DIFF( ${TABLE}.scene_end,${TABLE}.scene_start,second) ;;
  }

  dimension: sub_location {
    group_label: "Location"
    label: "Sub Location"
    type: string
    sql: ${TABLE}.sub_location ;;
    map_layer_name: major_locations ##TODO ADD NEW LOCATIONS
  }

  dimension: warg {
    label: "Warg?"
    type: yesno
    sql: ${TABLE}.warg = "true" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: scene_length_seconds {
    label: "Scene Length (s)"
    type: sum_distinct
    group_label: "Scene Length"
    sql: ${scene_length_secs} ;;
    sql_distinct_key: ${unique_scene} ;;
    drill_fields: [detail*]
  }

  measure: scene_length_minutes {
    label: "Scene Length (m)"
    group_label: "Scene Length"
    type: sum_distinct
    sql: ${scene_length_secs}/60 ;;
    sql_distinct_key: ${unique_scene} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [season_num,episode_num,unique_scene,location,sub_location]
  }
}

```
I also built another view off the same table, scene_characters, which was useful for modelling purposes.
```
view: scene_characters {
  sql_table_name: game_of_thrones_19.scenes ;;

  dimension: characters_name {
    type: string
    hidden: yes
    #For joining characters in
    sql: ${TABLE}.characters_name ;;
  }

  dimension: scene_id {
  description: "Unique Scene ID *within episode*. Scene start + scene_end"
    #Unique ID of scene within episode
    type: string
    sql: CONCAT(CAST(${TABLE}.scene_start AS string), '-', CAST(${TABLE}.scene_end AS string)) ;;
    primary_key: no
  }

  dimension: unique_ep {
    label: "Unique Episode"
    description: "Season + Episode combo"
    #The season/episode unique combo
    type: string
    sql: CONCAT(CAST(${TABLE}.season_num AS string), "-",CAST(${TABLE}.episode_num AS string)) ;;
  }

  dimension: pk {
    #Generated Row_Number over the entire dataset, means nothing but uniqueness
    type: number
    sql: ${TABLE}.pk ;;
    hidden: yes
    primary_key: yes
  }

  dimension: unique_scene {
    description: "Season - Episode - Scene combination"
    type: string
    sql: concat(${unique_ep},"-", ${scene_id}) ;;
    primary_key: no
  }

  dimension: characters_alive {
    description: "Was character alive in this scene?"
    label: "Is Alive?"
    type: yesno
    sql:${TABLE}.characters_alive IS NULL ;;
  }

  dimension: characters_born {
    description: "Was character born in this scene?"
    label: "Is Born?"
    type: yesno
    sql: ${TABLE}.characters_born ;;
  }

  dimension: characters_killed_by {
    description: "Who killed the selected character in the scene"
    label: "Is Killed By"
    type: string
    sql: ${TABLE}.characters_killed_by ;;
  }

  dimension: characters_manner_of_death {
    label: "Manner of Death"
    description: "How Character died. Sometimes a bit vague."
    type: string
    sql: ${TABLE}.characters_manner_of_death ;;
  }

  dimension: characters_married_consummated {
    group_label: "Marriage"
    label: "Is Marriage Consummated?"
    type: yesno
    sql: ${TABLE}.characters_married_consummated ;;
  }

  dimension: characters_married_to {
    group_label: "Marriage"
    label: "Married To"
    type: string
    sql: ${TABLE}.characters_married_to ;;
  }

  dimension: characters_married_type {
    group_label: "Marriage"
    label: "Marriage Type"
    type: string
    sql: ${TABLE}.characters_married_type ;;
  }

  dimension: characters_married_when {
    group_label: "Marriage"
    label: "Married When"
    type: string
    sql: ${TABLE}.characters_married_when ;;
  }

  dimension: characters_sex_type {
    group_label: "Sex"
    label: "Sex Type"
    description: "Type of Sex, from the raw data."
    type: string
    sql: ${TABLE}.characters_sex_type ;;
  }

  dimension: characters_sex_when {
    group_label: "Sex"
    label: "Sex When"
    description: "Past, Present, or Future"
    type: string
    sql: ${TABLE}.characters_sex_when ;;
  }

  dimension: characters_sex_with {
    group_label: "Sex"
    label: "Sex With"
    description: "Name of Character"
    type: string
    sql: ${TABLE}.characters_sex_with ;;
  }

  # dimension: characters_title {
  #   label: ""
  #   type: string
  #   sql: ${TABLE}.characters_title ;;
  # }

  dimension: characters_weapon_action {
    group_label: "Weapon"
    label: "Weapon Action"
    type: string
    sql: ${TABLE}.characters_weapon_action ;;
  }

  dimension: characters_weapon_name {
    group_label: "Weapon"
    label: "Weapon Name"
    type: string
    sql: ${TABLE}.characters_weapon_name ;;
  }

  measure: count_deaths {
  type: count
   filters: {
     field: characters_killed_by
     value: "-NULL"
   }
  sql_distinct_key: CONCAT(${characters_name}, CAST(${pk} AS string)) ;;
  drill_fields: [characters_name, characters_killed_by, characters_manner_of_death]
  }


}
```

#### *The model*
All of these views come together into just 4 explores. Characters, Episodes, Scene-Level Detail, and Scripts.
Characters:
```
explore: characters {
  persist_for: "60000 minutes"
  view_name: character_facts
  label: "Characters"
  view_label: "Characters"
  join: characters {
    view_label: "Characters"
    fields: [characters.abducted,characters.abducted_by,characters.allies,characters.kingsguard,characters.married_engaged,characters.royal]
    type: left_outer
    relationship: one_to_one
    sql_on: ${character_facts.name} = ${characters.character_name} ;;
  }
  join: scene_characters {
    relationship: one_to_many
    fields: []
    sql_on: ${scene_characters.characters_name} = ${character_facts.name} ;;
  }
  join: scenes {
    relationship: one_to_many
    fields: []
    sql_on: ${scenes.scene_id} = ${scene_characters.scene_id};;
  }
}
```
Episodes:
```
explore: episodes {
  persist_for: "60000 minutes"
  sql_always_where: ${season_num} != 8 ;; # Remove Season 8 null references
  label: "Episodes"
  description: "Episode Level Data"
  join: death_episode {
    view_label: "Deaths"
    type: left_outer
    sql_on: ${episodes.unique_episode} = ${death_episode.unique_episode} AND ${death_episode.character_name} = ${characters.character_name}   ;;
    relationship: one_to_many
  }
  join: sex_episode {
    view_label: "Sex"
    type: left_outer
    sql_on: ${episodes.unique_episode} = ${sex_episode.unique_episode} AND ${sex_episode.character_name} = ${scene_characters.characters_name}  ;;
    relationship: one_to_many
  }
  join: scenes {
    fields: []
    type: left_outer
    relationship: one_to_many
    sql_on: ${scenes.unique_ep} = ${episodes.unique_episode} ;;
  }
  join: scene_characters {
    fields: []
    relationship: one_to_many
    view_label: "Scene Actions"
    type: left_outer
    sql_on: ${scenes.pk} = ${scene_characters.pk} ;;
  }
  join: characters {
    relationship: many_to_one
    view_label: "Characters"
    type: left_outer
    sql_on: ${characters.character_name} = ${scene_characters.characters_name} ;;
  }
  join: character_facts {
    relationship: one_to_one
    view_label: "Characters"
    type: left_outer
    sql_on: ${character_facts.name} = ${characters.character_name} ;;
  }
}
```
Scene Level Detail:
```
explore: scene_level_detail {
  persist_for: "60000 minutes"
  sql_always_where: ${season_num} != 8 ;; # Remove Season 8 null references
  view_name: episodes
  label: "Scene Level Detail"
  join: scenes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${scenes.unique_ep} = ${episodes.unique_episode} ;;
  }

  join: scene_characters {
    view_label: "Scene Actions"
    type: left_outer
    relationship: one_to_many
    sql_on: ${scenes.pk} = ${scene_characters.pk} ;;
  }

  join: characters {
    view_label: "Characters"
    type: left_outer
    relationship: many_to_one
    sql_on: ${characters.character_name} = ${scene_characters.characters_name} ;;
  }
  join: character_facts {
    view_label: "Characters"
    type: left_outer
    relationship: one_to_one
    sql_on: ${characters.character_name} = ${character_facts.name} ;;
  }
}
```
And Scripts:
```
explore: scripts {
  persist_for: "60000 minutes"
  #This explore contains line-level script information.
  #Scripts_unnested is broken up by word, to do a word cloud with
  fields: [ALL_FIELDS*,-episodes.scene_length,-character_facts.screentime_seconds,-character_facts.screentime_minutes]
  #Lines
  join: scripts_unnested {
    type: left_outer
    relationship: many_to_many
    view_label: "Broken Up By Word"
    sql_on: ${scripts.episode} = ${scripts_unnested.episode} AND ${scripts.speaker} = ${scripts_unnested.speaker} ;;
  }

  join: character_facts {
    view_label: "Characters"
    type: left_outer
    relationship: one_to_one
    sql_on: ${character_facts.firstname} = ${scripts.speaker} AND ${character_facts.name} != "Jon Arryn" ;;
  }

  join: characters {
    type: left_outer
    relationship: many_to_many
    sql_on: ${character_facts.name} = ${characters.character_name} ;;
  }


  join: episodes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${scripts.episode} = ${episodes.title} ;;
  }
}
```


There are some other loose ends, like `locations`— I actually created a custom topojson of westeros, which you can see in the repo but I couldn't get it to work well enough under the time constraints to open it up the public. In a nutshell, though, that's the model! 

#### *The presentation*
The dashboards are nothing too special, actually! The incredible Maire Newton and Sooji Kim (who also helped massively with the model building!!!) are excellent at building beautiful dashboards. Nuff said. 

We leveraged some html in text tiles to make things centered and pop out
```
**New to Looker?** Check out our guide to <a href="https://discourse.looker.com/t/getting-started-with-looker/11821?utm_campaign=70144000001JCJ0&utm_source=play.looker.com&utm_medium=referral&utm_content=DataOfThronesGoTCampaignQ2Y19" target="_blank">Getting Started with Looker</a>.

**Don't know where to get started?** Browse through this dashboard for some examples of visualizations you can create. Hover & click around to explore the data.

**Questions?** Post them on the Looker Community in the <a href="https://discourse.looker.com/t/data-of-thrones-q-a-post-questions-here/11798?utm_campaign=70144000001JCJ0&utm_source=play.looker.com&utm_medium=referral&utm_content=DataOfThronesGoTCampaignQ2Y19" target="_blank">Q&A thread.</a>

**Found cool stuff?** Post it on the <a href="https://discourse.looker.com/c/fun-with-data/data-of-thrones?utm_campaign=70144000001JCJU&utm_source=looker.com/dataofthrones&utm_medium=redirect&utm_content=DataOfThronesGoTCampaignQ2Y19" target="_blank">Data of Thrones forum</a> and tweet it <a href="https://twitter.com/LookerData" target="_blank">@LookerData</a> with #dataofthrones!

**Want Looker for your data?** <a href="https://looker.com/demo?utm_campaign=70144000001JCJ0&utm_source=play.looker.com&utm_medium=referral&utm_content=DataOfThronesGoTCampaignQ2Y19" target="_blank">Request a demo</a> and see your data in a new way.
```
But aside from that, it's just a plain vanilla Looker dashboard that had a lot of thought go into layout. It was embedded, so we could add themes to make the entire thing white. Un-embedded, it looks a little bit uglier and you can better see how it's laid out :) ![image|690x347](https://i.imgur.com/yrL2dNt.png) 
