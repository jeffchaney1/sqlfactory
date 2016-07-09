using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class GroupByColumn : Column
    {
    }

    public class GroupByList : CustomColumnList<GroupByColumn>
    {

        public GroupByColumn Insert(int columnPosition, String tableName, String columnName)
        {
            GroupByColumn result = new GroupByColumn();
            result.TableName = tableName;
            result.ColumnName = columnName.Trim();
            return result;
        }

        public GroupByColumn Insert(int columnPosition, SelectColumn column)
        {
            if (column == null)
                return null;

            return this.Insert(columnPosition, column.TableName, column.ColumnName);
        }

        public GroupByColumn Insert(int columnPosition, String columnExpression)
        {
            int p = columnExpression.LastIndexOf('.');
            String tmpTableName = "";
            if (p > 0)
            {
                tmpTableName = columnExpression.Substring(0, p);
                columnExpression = columnExpression.Substring(p + 1);
            }

            return Insert(columnPosition, tmpTableName, columnExpression);
        }

        public GroupByColumn Add(String columnExpression)
        {
            return this.Insert(this.Count(), columnExpression);
        }

        public void Add(String[] columnInfo)
        {
            foreach (String expression in columnInfo)
            {
                Add(expression);
            }
        }

        public GroupByColumn Add(String tableAlias, String columnExpression)
        {
            return Insert(this.Count(), tableAlias, columnExpression);
        }

        public GroupByColumn Add(SelectColumn column)
        {
            return Insert(this.Count(), column);
        }

    }
}
