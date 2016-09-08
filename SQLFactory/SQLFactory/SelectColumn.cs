using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class SelectColumn : Column
    {
        public String ColumnAlias { get; set; }
        public String IsNullDefaultValueRaw { get; set; }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (!String.IsNullOrEmpty(this.IsNullDefaultValueRaw))
                sql.Append("ISNULL(");

            base.BuildSQL(sql, parameters, indent);

            if (!String.IsNullOrEmpty(this.IsNullDefaultValueRaw))
            {
                sql.Append(',');
                sql.Append(this.IsNullDefaultValueRaw);
                sql.Append('(');
            }
            if (!this.ColumnName.Equals(this.ColumnAlias) || !String.IsNullOrEmpty(this.IsNullDefaultValueRaw))
            {
                sql.Append(' ');
                if (this.AddDelimiters)
                    sql.Append('[');
                if  (!String.IsNullOrEmpty(this.ColumnAlias) )
                    sql.Append(this.ColumnAlias);
                else if (this.IsIdentifier(this.ColumnName)) {
                    sql.Append(this.ColumnName);
                }
                else {
                    sql.Append(this.MyIdent("COL_", !AddDelimiters));
                }

                if (this.AddDelimiters)
                    sql.Append(']');

            }
        }

        public override bool IsMatch(string key)
        {
            return this.ColumnAlias.Equals(key, StringComparison.OrdinalIgnoreCase);
        }
    }

    public class SelectColumnList : CustomColumnList<SelectColumn>
    {
        public SelectColumn Insert1(int columnPos, String tableName, String columnName, String columnAlias) {
            SelectColumn result = new SelectColumn();
            result.TableName = tableName;
            result.ColumnName = columnName;
            if (String.IsNullOrEmpty(columnAlias)) 
                result.ColumnAlias = columnName;
            else
                result.ColumnAlias = columnAlias;

            base.Insert(columnPos, result);
            return result;
        }

        public SelectColumn Insert1(int columnPos, String columnExpression, String columnAlias = "") {

            String tmpTableAlias = "";
            String tmpColExpr = columnExpression;
            String tmpColAlias = columnAlias;

            SQLFactory.ParseColumnInfo(columnExpression, out tmpTableAlias, out tmpColExpr, out tmpColAlias);

            if (!String.IsNullOrEmpty(columnAlias))
            {
                tmpColAlias = columnAlias;
            }

            return this.Insert1(columnPos, tmpTableAlias, tmpColExpr, tmpColAlias);
        }

        public void Insert(int columnPos, params String[] columnInfo)
        {
            foreach(var columnExpression in columnInfo)
            {
                if (columnExpression == null)
                    continue;
                // Process the columnInfo element as if it were a comma separated list 
                //  of columns
                int p = 0;
                while(p < columnExpression.Length) {
                    String tmpColExpr = columnExpression.ParseNext(ref p, ",", "\"", "[]");
                    Insert1(columnPos, tmpColExpr);
                }

            }
        }

        public SelectColumn Add1(String columnExpression, String columnAlias = "") {
            return this.Insert1(this.Count(), columnExpression, columnAlias);
        }

        public SelectColumn Add1(String tableAlias, String columnExpression, String columnAlias)
        {
            return this.Insert1(this.Count(), tableAlias, columnExpression, columnAlias);
        }

        public void Add(params String[] columnInfo)
        {
            this.Insert(this.Count(), columnInfo);
        }

    }
}
