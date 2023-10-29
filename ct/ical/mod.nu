use ct/core *

const db = ("~/Library/Calendars/Calendar.sqlitedb" | path expand)

# List out calendars
export def calendars [] {
  nuopen $db | get Calendar | select title ROWID
}

# List out all events for a given calendar
export def events [calendar: string] {
  let calendar_id = (calendars | where title =~ $calendar | first | get ROWID)

  let timestamps = [start_date end_date last_modified creation_date]

  nuopen $db 
  | get CalendarItem 
  | where calendar_id == $calendar_id
  | select summary location_id description start_date end_date all_day calendar_id status invitation_status availability url last_modified hidden has_recurrences has_attendees due_date creation_date app_link conference_url
  | par-each {|r|
    $r | merge (
      $r | map-to-durations $timestamps --daylight-savings --zero-year 2001
    )
  }
}

# For a given set of columns, update each from a sqlite zero time to a nushell duration
def map-to-durations [
  columns: list<string>
  --zero-year: int
  --daylight-savings
]: table -> table {
  let row = $in

  echo $columns 
  | filter { |col| $row | get $col | is-not-empty }
  | reduce --fold {} { |col, dates| 
    let dur = (echo $row 
      | get $col 
      | from zero-time $zero_year --offset (if $daylight_savings { -1 } else { 0 }))

    $dates | upsert $col $dur
  }
}

# Convert from a "since zero" duration, e.g from MySQL
# there are probably better ways to do this!
def "from zero-time" [
  year = 2000 # year of start, e.g 0000 for gregorian
  --offset = 0 # offset to adjust by in hours
] {
  ($"($year)-01-01" | into datetime) + (($"($in)sec" | into duration) - ($"($offset)hr" | into duration))
}
