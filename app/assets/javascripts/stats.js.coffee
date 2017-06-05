# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('[data-controller=stats][data-action=index]').ready ->
  new Calendar({
    element: $('.daterange--double'),
    earliest_date: '2000-01-1',
    latest_date: moment(),
    start_date: '2015-05-01',
    end_date: '2015-05-31',
    callback: () =>
      start = moment(this.start_date).format('ll')
      end = moment(this.end_date).format('ll')

      console.debug('Start Date: '+ start +'\nEnd Date: '+ end)
  })

  ctx = document.getElementById("totalSessionsChart").getContext("2d")
  options = {
    legend: {
      display: false
    },
    scales: {
      yAxes: [{
        ticks: {
          min: 0,
          beginAtZero: true
          callback: (value, index, values) ->
            if (Math.floor(value) == value)
              return value
        }
      }]
    }
  }

  $.get "/listens.json", (listens) ->
    data = {
      labels: _.keys(listens)
      datasets: [
          {
              label: "listens",
              fillColor: "rgba(220,220,220,0.2)",
              strokeColor: "rgba(220,220,220,1)",
              pointColor: "rgba(220,220,220,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#fff",
              pointHighlightStroke: "rgba(220,220,220,1)",
              data: _.values(listens)
          },
      ]

    }
    listensChart = new Chart(ctx, { type: 'line', data: data, options: options })
