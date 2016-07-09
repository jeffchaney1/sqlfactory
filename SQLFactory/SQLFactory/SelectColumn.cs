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
        public SelectColumn Insert(int columnPos, String tableName, String columnName, String columnAlias) {
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

        public SelectColumn Insert(int columnPos, String columnExpression, String columnAlias = "") {
            String tmpTableAlias = "";
            String tmpColExpr = columnExpression;
            String tmpColAlias = columnAlias;

            if (String.IsNullOrEmpty(columnAlias))
            {
                SQLFactory.ParseColumnInfo(columnExpression, out tmpTableAlias, out tmpColExpr, out tmpColAlias);
            }

            return this.Insert(columnPos, tmpTableAlias, tmpColExpr, tmpColAlias);
        }

        public void Insert(int columnPos, String[] columnInfo)
        {
            for (int i = columnInfo.Length - 1; i > -1; i--)
            {
                int p = 0;
                String tmpColExpr = columnInfo[i].ParseNext(ref p, ", ", "\"", "[]");
                String tmpColAlias = columnInfo[i].ParseNext(ref p, ", ", "\"", "[]");

                Insert(columnPos, tmpColExpr, tmpColAlias);

            }
        }

        public SelectColumn Add(String columnExpression, String columnAlias = "") {
            return this.Insert(this.Count(), columnExpression, columnAlias);
        }

        public SelectColumn Add(String tableAlias, String columnExpression, String columnAlias)
        {
            return this.Insert(this.Count(), tableAlias, columnExpression, columnAlias);
        }

        public void Add(String[] columnInfo)
        {
            this.Insert(this.Count(), columnInfo);
        }

    }
}
