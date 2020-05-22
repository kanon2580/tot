$("#totalChart").ready(function (){
  var ctx = document.getElementById("totalChart");
  var radarChart = new Chart(ctx, {
    type: 'radar',
    data: {
      labels: ["Time to response", "Time to solved", "Likes", "Best answer", "Issue viewed"],
      datasets: [{
        label: gon.user_name,
        backgroundColor: 'rgba(255,180,153,0.4)',
        borderColor: 'rgba(255,127,80,1)',
        borderWidth: 1,
        pointRadius: 2,
        data: gon.user_scores
      }]
    },
    options: {
      legend: {
        display: false,
      },
      scale: {
        ticks: {
          min: 0,
          max: 10
        }
      }
    }
  })
  return radarChart;
});
