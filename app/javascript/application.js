// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "chartkick"
import "Chart.bundle"

Chart.defaults.font.family = "'Space Grotesk', sans-serif";
const chartBackgroundPlugin = {
  id: 'customBackground',
  beforeDraw: (chart) => {
    const { ctx, chartArea } = chart;
    ctx.save();
    ctx.fillStyle = "rgb(45, 63, 102)";
    ctx.fillRect(
      chartArea.left,
      chartArea.top,
      chartArea.width,
      chartArea.height
    );
    ctx.restore();
  }
};
Chart.register(chartBackgroundPlugin);

