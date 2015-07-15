# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $("#calendar").fullCalendar
    defaultView: 'agendaWeek'
    allDaySlot: false
    header:
      left: 'prev,next today'
      center: 'title'
      right: 'month,agendaWeek,agendaDay'
    firstDay: 1
    businessHours:
      start: '10:00'
      end: '18:00'
      dow: [1,2,3,4,5]
    events: '/goals/calendar.json'
    editable: true
    eventDrop: (event, delta, revertFunc) ->
      if confirm("Are you sure?")
        if event.repeatable
          if !confirm("Change for all repeating events?")
            set_new = true
          else
            set_new = false
        $.ajax
          url: '/goals/changegoaltime'
          data: id: event.id,
          set_new: set_new,
          start: event.start.format(),
          end: event.end.format()
          type: 'POST'
          dataType: 'json'
          cache: false
      else
        revertFunc()
    eventResize: (event, delta, revertFunc) ->
      if confirm("Are you sure?")
        if event.repeatable != ""
          if !confirm("Change for all repeating events?")
            set_new = true
          else
            set_new = false
        $.ajax
          url: '/goals/changegoaltime'
          data: id: event.id,
          set_new: set_new,
          start: event.start.format(),
          end: event.end.format()
          type: 'POST'
          dataType: 'json'
          cache: false
      else
        revertFunc()
