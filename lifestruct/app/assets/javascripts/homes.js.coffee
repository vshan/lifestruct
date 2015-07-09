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


