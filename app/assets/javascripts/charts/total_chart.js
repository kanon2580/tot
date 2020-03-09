// document.addEventListener("turbolinks:load", function(){ // ターボリンクのイベント取得
  // var gon_tmp = document.getElementById("gon_base").children[0]; // headのgonをイベント発火後に呼び出し(配列,scriptタグ)
  // document.body.appendChild(gon_tmp); // body末尾に呼び出したgonを追加
  var ctx = document.getElementById("totalChart"); // 以下チャート呼び出し
  var totalChart = new Chart(ctx, {
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
// });