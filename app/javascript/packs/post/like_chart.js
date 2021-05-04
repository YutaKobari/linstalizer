import "chart.js"

$(window).on('load', function () {
    const ctx = $('#like-trans-chart');
    const data = $('#like-chart-data').data('like-chart');
    const chart = new Chart(ctx,
        {
            type: `line`,
            data: {
                labels: data.labels,
                datasets: [
                    {
                        label: 'いいね',
                        data: data.data,
                    }
                ]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            callback: function (label) {
                                return label.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                            }
                        }
                    }]
                },
                tooltips: {
                    callbacks: {
                        label: function (tooltipItem) {
                            return tooltipItem.yLabel.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                        }
                    }
                }
            }
        }
    );
});
