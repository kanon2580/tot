var ctx = document.getElementById('issueViewedChart').getContext('2d');
var issueViewedChart = new Chart(ctx, {
	type: 'bar',
	data: {
		labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
		datasets: [{
			label: "Users",
			data: gon.issue_viewed_count_evaluation,
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
