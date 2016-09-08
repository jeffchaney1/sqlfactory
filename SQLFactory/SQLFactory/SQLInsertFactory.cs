using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class SQLInsertFactory : SQLModifyFactory
    {
        public Table IntoTable { get { return GetTable(); } }
        public FieldValueList Columns { get { return GetColumns(); } }

        private SQLSelectFactory fromQuery;
        public SQLSelectFactory FromQuery
        {
            get
            {
                if (this.fromQuery == null)
                    this.fromQuery = new SQLSelectFactory();
                return this.fromQuery;
            }

            set { this.fromQuery = value; }
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            sql.Append(indent);
            sql.Append("INSERT INTO ");

            this.InternalBuildModifyTable(sql, parameters, indent);

            sql.Append('\n');

            this.InternalBuildColumnList(sql, parameters, indent);

            sql.Append('\n');

            this.InternalBuildValuesList(sql, parameters, indent);
        }

        protected void InternalBuildColumnList(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (Columns.Count > 0) {
                sql.Append('(');
                Columns.BuildSQL(sql, parameters, indent);
                sql.Append(") ");
            }
        }

        protected void InternalBuildValuesList(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (!Columns.BuildValuesList(sql, parameters, indent)) {
                if (!String.IsNullOrEmpty(fromQuery.FromTable.TableName)) {
                    fromQuery.BuildSQL(sql, parameters, indent);
                }
                else
                    throw new ESQLFactoryException("No source for values to be inserted has been defined");
            }
        }


    }
}
