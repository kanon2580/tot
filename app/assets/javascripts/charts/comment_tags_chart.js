var ctx = document.getElementById("commentTagsChart");
var commentTagsChart = new Chart(ctx, {
  type: 'doughnut',
  data: {
    labels: gon.comment_tags_labels,
    datasets: [{
        data: gon.comment_tags_evaluation_datas,
        backgroundColor: ['rgba(52,58,64,0.4)', 'rgba(255,127,80,0.4)'],
        borderColor: ['rgba(52,58,64,1)', 'rgba(255,127,80,1)']
    }]
  }
});
