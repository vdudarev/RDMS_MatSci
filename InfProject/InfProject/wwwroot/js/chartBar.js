import Chart from '/js/chart.min.js/auto';
import { getRelativePosition } from '/js/chart.min.js';

const ctx = document.getElementById('myChart').getContext('2d');
const myChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: app.chart.labels,
        datasets: [{
            label: app.chart.title,
            data: app.chart.data,
            backgroundColor: 'rgba(54, 162, 235, 0.2)',
            borderColor: 'rgba(54, 162, 235, 1)',
            borderWidth: 1
        }]
    }
    , options: {
        scales: {
            y: {
                beginAtZero: true
            }
        },
        onClick: (e) => {
            const canvasPosition = getRelativePosition(e, chart);
            // Substitute the appropriate scale IDs
            const dataX = chart.scales.x.getValueForPixel(canvasPosition.x);
            const dataY = chart.scales.y.getValueForPixel(canvasPosition.y);
            console.log("Chart Click: " + dataX + ", " + dataY);
        }
    }
});
