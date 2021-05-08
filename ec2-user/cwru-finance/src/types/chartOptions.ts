export const chartOptions = (newCategories:any) => {
    return {
        chart: {
          id: "priceChange",
        },
        xaxis: {
          labels: {
            show: false
          },
          axiosBorder: {
            show: false
          },
          axisTicks: {
            show: false
          },
          categories: newCategories
        },
        yaxis: {
          labels: {
            "formatter": function (val:number) {
                return val.toFixed(0)
            }
        }
        }
      };
};
export const chartOptions2 = (newCategories:any) => {
    return {
        chart: {
          id: "volume",
        },
        grid: {
          show: false
        },
        dataLabels: {
          enabled: false
        },
        yaxis: {
          show: true,
          tickAmount: 1,
          axisTicks: {
          show: false,
          color: '#ffffff00',
          },
          labels: {
            style: {
              colors: ['#ffffff00'],
              fontSize: '4px',
              fontFamily: 'Helvetica, Arial, sans-serif',
              fontWeight: 10,
              cssClass: 'apexcharts-yaxis-label',
            }
            }
        },
        xaxis: {
          categories: newCategories,
          labels: {
          show: true,
          rotate: 0,
          rotateAlways: false,
          hideOverlappingLabels: true,
          showDuplicates: false,
          trim: false,
          offsetX: 5
          },
          tickAmount: 5,
        },
      };
};
