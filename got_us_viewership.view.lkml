view: got_us_viewership {
  derived_table: {
    sql: select '2011417' as month, '1' as season_number, '1' as overall_number, 'Winter Is Coming' as episode_title, '2.22' as US_viewership_number
      union select '2011424', '1', '2', 'The Kingsroad', '2.2'
      union select '201151', '1', '3', 'Lord Snow', '2.44'
      union select '201158', '1', '4', 'Cripples Bastards and Broken Things', '2.45'
      union select '2011515', '1', '5', 'The Wolf and the Lion', '2.58'
      union select '2011522', '1', '6', 'A Golden Crown', '2.44'
      union select '2011529', '1', '7', 'You Win or You Die', '2.4'
      union select '201165', '1', '8', 'The Pointy End', '2.72'
      union select '2011612', '1', '9', 'Baelor', '2.66'
      union select '2011619', '1', '10', 'Fire and Blood', '3.04'
      union select '201241', '2', '11', 'The North Remembers', '3.86'
      union select '201248', '2', '12', 'The Night Lands', '3.76'
      union select '2012415', '2', '13', 'What Is Dead May Never Die', '3.77'
      union select '2012422', '2', '14', 'Garden of Bones', '3.65'
      union select '2012429', '2', '15', 'The Ghost of Harrenhal', '3.9'
      union select '201256', '2', '16', 'The Old Gods and the New', '3.88'
      union select '2012513', '2', '17', 'A Man Without Honor', '3.69'
      union select '2012520', '2', '18', 'The Prince of Winterfell', '3.86'
      union select '2012527', '2', '19', 'Blackwater', '3.38'
      union select '201263', '2', '20', 'Valar Morghulis', '4.2'
      union select '2013331', '3', '21', 'Valar Dohaeris', '4.37'
      union select '201347', '3', '22', 'Dark Wings, Dark Words', '4.27'
      union select '2013414', '3', '23', 'Walk of Punishment', '4.72'
      union select '2013421', '3', '24', 'And Now His Watch Is Ended', '4.87'
      union select '2013428', '3', '25', 'Kissed by Fire', '5.35'
      union select '201355', '3', '26', 'The Climb', '5.5'
      union select '2013512', '3', '27', 'The Bear and the Maiden Fair', '4.84'
      union select '2013519', '3', '28', 'Second Sons', '5.13'
      union select '201362', '3', '29', 'The Rains of Castamere', '5.22'
      union select '201369', '3', '30', 'Mhysa', '5.39'
      union select '201446', '4', '31', 'Two Swords', '6.64'
      union select '2014413', '4', '32', 'The Lion and the Rose', '6.31'
      union select '2014420', '4', '33', 'Breaker of Chains', '6.59'
      union select '2014427', '4', '34', 'Oathkeeper', '6.95'
      union select '201454', '4', '35', 'First of His Name', '7.16'
      union select '2014511', '4', '36', 'The Laws of Gods and Men', '6.4'
      union select '2014518', '4', '37', 'Mockingbird', '7.2'
      union select '201461', '4', '38', 'The Mountain and the Viper', '7.17'
      union select '201468', '4', '39', 'The Watchers on the Wall', '6.95'
      union select '2014615', '4', '40', 'The Children', '7.09'
      union select '2015412', '5', '41', 'The Wars to Come', '8'
      union select '2015419', '5', '42', 'The House of Black and White', '6.81'
      union select '2015426', '5', '43', 'High Sparrow', '6.71'
      union select '201553', '5', '44', 'Sons of the Harpy', '6.82'
      union select '2015510', '5', '45', 'Kill the Boy', '6.56'
      union select '2015517', '5', '46', 'Unbowed, Unbent, Unbroken', '6.24'
      union select '2015524', '5', '47', 'The Gift', '5.4'
      union select '2015531', '5', '48', 'Hardhome', '7.01'
      union select '201567', '5', '49', 'The Dance of Dragons', '7.14'
      union select '2015614', '5', '50', 'Mothers Mercy', '8.11'
      union select '2016424', '6', '51', 'The Red Woman', '7.94'
      union select '201651', '6', '52', 'Home', '7.29'
      union select '201658', '6', '53', 'Oathbreaker', '7.28'
      union select '2016515', '6', '54', 'Book of the Stranger', '7.82'
      union select '2016522', '6', '55', 'The Door', '7.89'
      union select '2016529', '6', '56', 'Blood of My Blood', '6.71'
      union select '201665', '6', '57', 'The Broken Man', '7.8'
      union select '2016612', '6', '58', 'No One', '7.6'
      union select '2016619', '6', '59', 'Battle of the Bastards', '7.66'
      union select '2016626', '6', '60', 'The Winds of Winter', '8.89'
      union select '2017716', '7', '61', 'Dragonstone', '10.11'
      union select '2017723', '7', '62', 'Stormborn', '9.27'
      union select '2017730', '7', '63', 'The Queens Justice', '9.25'
      union select '201786', '7', '64', 'The Spoils of War', '10.17'
      union select '2017813', '7', '65', 'Eastwatch', '10.72'
      union select '2017820', '7', '66', 'Beyond the Wall', '10.24'
      union select '2017827', '7', '67', 'The Dragon and the Wolf', '12.07'
      union select '2019414', '8', '68', 'Winterfell', '11.76'
      union select '2019421', '8', '69', 'A Knight of the Seven Kingdoms', '10.29'
      union select '2019428', '8', '70', 'The Long Night', '12.02'
      union select '201955', '8', '71', 'The Last of the Starks', '11.8'
      union select '2019512', '8', '72', 'The Bells', '12.48'
      union select '2019519', '8', '73', 'The Iron Throne', '13.61'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: month {
    type: string
    sql: ${TABLE}.month ;;
  }

  dimension: unique_episode {
    type: string
    primary_key: yes
    sql: CONCAT(CAST(${season_number} AS string),"-",CAST(${episode_number} AS string)) ;;
  }

  dimension: season_number {
    type: string
    sql: ${TABLE}.season_number ;;
  }

  dimension: episode_number {
    type: string
    sql: ${TABLE}.overall_number ;;
  }

  dimension: episode_title {
    type: string
    sql: ${TABLE}.episode_title ;;
  }

  dimension: us_viewership_number {
    type: string
    sql: ${TABLE}.us_viewership_number ;;
  }

  set: detail {
    fields: [month, season_number, episode_number, episode_title, us_viewership_number]
  }
}
