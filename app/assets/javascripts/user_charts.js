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
    }
  });
  return radarChart;
});

$("#likeChart").ready(function (){
  chart_id = "likeChart";
  datas = gon.like_evaluation_datas;
  bar_chart(chart_id, datas);
});
$("#issueViewedChart").ready(function (){
  chart_id = "issueViewedChart";
  datas = gon.issue_viewed_evaluation_datas;
  bar_chart(chart_id, datas);
});
$("#responseChart").ready(function (){
  chart_id = "responseChart";
  datas = gon.response_evaluation_datas;
  bar_chart(chart_id, datas);
});
$("#requiredTimeChart").ready(function (){
  chart_id = "requiredTimeChart";
  datas = gon.required_time_evaluation_datas;
  bar_chart(chart_id, datas);
});
$("#bestAnswerChart").ready(function (){
  chart_id = "bestAnswerChart";
  datas = gon.best_answer_evaluation_datas;
  bar_chart(chart_id, datas);
});

$("#issueTagsChart").ready(function (){
  chart_id = "issueTagsChart";
  labels = gon.issue_tags_labels;
  datas = gon.issue_tags_evaluation_datas;
  doughnut_chart(chart_id ,labels, datas);
});
$("#issueTagsChart").ready(function (){
  chart_id = "commentTagsChart";
  labels = gon.comment_tags_labels;
  datas = gon.comment_tags_evaluation_datas;
  doughnut_chart(chart_id ,labels, datas);
});

function bar_chart(chart_id, datas){
  var ctx = document.getElementById(chart_id).getContext('2d');
  var barChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
      datasets: [{
        label: "Users",
        data: datas,
        backgroundColor: 'rgba(52,58,64,0.4)',
        borderColor: 'rgba(52,58,64,1)',
        borderWidth: 1
      }]
    },
    options: {
      scales: {
        yAxes: [{
          ticks: {
            beginAtZero: true
          }
        }]
      }
    }
  });
  return barChart;
}

function doughnut_chart(chart_id,labels,datas){
  var ctx = document.getElementById(chart_id);
  var doughnutChart = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [{
        data: datas,
        backgroundColor: ['rgba(52,58,64,0.4)', 'rgba(255,127,80,0.4)'],
        borderColor: ['rgba(52,58,64,1)', 'rgba(255,127,80,1)']
      }]
    }
  });
return doughnutChart;
}
