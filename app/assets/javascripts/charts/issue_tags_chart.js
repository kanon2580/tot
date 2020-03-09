var ctx = document.getElementById("issueTagsChart");
var issueTagsChart = new Chart(ctx, {
  type: 'doughnut',
  data: {
    labels: gon.issue_tags_labels,
    datasets: [{
        data: gon.issue_tags_evaluation_datas,
        backgroundColor: ['rgba(52,58,64,0.4)', 'rgba(255,127,80,0.4)'],
        borderColor: ['rgba(52,58,64,1)', 'rgba(255,127,80,1)']
    }]
  }
});