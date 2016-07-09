using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class OrderByColumn : Column
    {
        public bool IsDescending { get; set; }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            base.BuildSQL(sql, parameters, indent);

            if (this.IsDescending)
                sql.Append(" DESC");
        }
    }

    public class OrderByList : CustomColumnList<OrderByColumn>
    {

        public OrderByColumn Insert(int columnPosition, String tableName, String columnName) {
            OrderByColumn result = new OrderByColumn();
            result.TableName = tableName;
            if (columnName.ToUpper().EndsWith(" DESC")) {
                result.IsDescending = true;
                result.ColumnName = columnName.Substring(0, columnName.Length-5).Trim();
            }
            else
                result.ColumnName = columnName.Trim();
            return result;
        }

        public OrderByColumn Insert(int columnPosition, SelectColumn column)
        {
            if (column == null)
                return null;

            return this.Insert(columnPosition, column.TableName, column.ColumnName);
        }

        public OrderByColumn Insert(int columnPosition, String columnExpression)
        {
            int p = columnExpression.LastIndexOf('.');
            String tmpTableName = "";
            if (p > 0) {
                tmpTableName = columnExpression.Substring(0, p);
                columnExpression = columnExpression.Substring(p + 1);
            }

            return Insert(columnPosition, tmpTableName, columnExpression);
        }

        public OrderByColumn Add(String columnExpression)
        {
            return this.Insert(this.Count(), columnExpression);
        }

        public void Add(String[] columnInfo)
        {
            foreach(String expression in columnInfo) {
                Add(expression);
            }
        }

        public OrderByColumn Add(String tableAlias, String columnExpression)
        {
            return Insert(this.Count(), tableAlias, columnExpression);
        }

        public OrderByColumn Add(SelectColumn column)
        {
            return Insert(this.Count(), column);
        }

    }
}
