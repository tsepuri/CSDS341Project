function capitalize(c:string): string {
    return c.charAt(0).toUpperCase() + c.substring(1);
}
interface column {
    header: string,
    field: string
}
function makeColumn(colName:string):column {
      return {
        header: colName.split("_").map(capitalize).join(" "),
        field: colName
      }
}
export const institutionalColumns:column[] = [
        makeColumn("asset_manager"),
        makeColumn("shares"),
        {
          field: 'position_value',
          header: 'Postition Value ($)'
        }
];
export const managerColumns:column[] = [
        {
          field: 'name',
          header: 'Name'
        },
        {
          field: 'role',
          header: 'Postition'
        }
]
export const insiderColumns:column[] = [
        {
          field: 'reporting_owner',
          header: "Owner"
        },
        makeColumn("transaction_date"),
        {
          field: 'acquisition_disposition',
          header: 'Acquisition/ Disposition'
        },
        makeColumn("transaction_type"),
        makeColumn("number_transacted")
      ];
export const financialColumns:column[] = [
        
        makeColumn("year"),
        makeColumn("quarter"),
        makeColumn("shares_outstanding"),
        {
          field: "total_assets",
          header: "Total Assets ($)"
        },
        {
          field: "total_equity",
          header: "Total Equity ($)"
        },
        {
          field: "total_liabilities",
          header: "Total Liabilities ($)"
        },
        {
          field: "total_revenue",
          header: "Total Revenue ($)"
        },
        {
          field: "cost_of_goods_sold",
          header: "Cost of Goods Sold ($)"
        },
        {
          field: "ebitda",
          header: "EBITDA ($)"
        },
        {
          field: "net_income",
          header: "Net Income ($)"
        },
        {
          field: "eps",
          header: "EPS ($)"
        },
        {
          field: "free_cash_flow",
          header: "Free Cash Flow ($)"
        }
      ];


  