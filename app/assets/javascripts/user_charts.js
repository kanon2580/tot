var chart_id;
var labels;
var datas;

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

$(function(){
  chart_id = "issueTagsChart";
  labels = gon.issue_tags_labels;
  datas = gon.issue_tags_evaluation_datas;
  doughnut_chart(chart_id ,labels, datas);

  chart_id = "commentTagsChart";
  labels = gon.comment_tags_labels;
  datas = gon.comment_tags_evaluation_datas;
  doughnut_chart(chart_id ,labels, datas);
})

function doughnut_chart(chart_id,labels,datas){
  var ctx = document.getElementById(chart_id);
  var doughnutChart = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [{
        data: datas,
        backgroundColor: 'rgba(52,58,64,0.4)',
        borderColor: 'rgba(52,58,64,1)'
      }]
    },
    options: {
      legend: {
        display: false
      }
    }
  });
return doughnutChart;
}
