import "chart.js"

$(window).on('load', function () {
    const ctx = $('#retweet-trans-chart');
    const data = $('#retweet-chart-data').data('retweet-chart');
    const chart = new Chart(ctx,
        {
            type: `line`,
            data: {
                labels: data.labels,
                datasets: [
                    {
                        label: 'リツイート',
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
