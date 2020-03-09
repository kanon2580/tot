var ctx = document.getElementById('requiredTimeChart').getContext('2d');
var requiredTimeChart = new Chart(ctx, {
	type: 'bar',
	data: {
		labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
		datasets: [{
			label: "Users",
			data: gon.required_time_evaluation_datas,
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
