using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public abstract class SQLModifyFactory : SQLElementParent
    {
        private Table table;
        protected Table GetTable() 
        {
            if (this.table == null)
                this.table = new Table();
            return this.table;
        }
        protected void SetTable(Table value) {this.table = value;}

        private FieldValueList columns;
        protected FieldValueList GetColumns() {
            if (this.columns == null)
                this.columns = new FieldValueList();
            return this.columns;
        }
        protected void SetColumns(FieldValueList value) {this.columns = value;}

        protected virtual void InternalBuildModifyTable(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            GetTable().BuildSQL(sql, parameters);
        }


    }

    public abstract class SQLConditionalModifyFactory : SQLModifyFactory
    {
        private ConditionList whereConditions;
        protected ConditionList GetWhere() {
            if (this.whereConditions == null)
                this.whereConditions = new ConditionList();
            return this.whereConditions;
        }

        private Boolean allowNoConditions;
        protected Boolean GetAllowNoConditions() { return this.allowNoConditions; }
        protected void SetAllowNoConditions(Boolean value) { this.allowNoConditions = value; }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if ((!GetAllowNoConditions()) && (GetWhere().Count == 0))
                throw new ESQLUpdateNoConditions("No conditions on which records are to be deleted have been defined.");

            InternalBuildModifyTable(sql, parameters, indent);

            InternalBuildWhereClause(sql, parameters, indent);
        }

        protected virtual void InternalBuildWhereClause(StringBuilder sql, ParameterList parameters, string indent)
        {
            if (GetWhere().Count > 0)
            {
                sql.Append('\n');
                sql.Append(indent);
                sql.Append(" WHERE ");
                GetWhere().BuildSQL(sql, parameters, indent);
            }
        }
    }
}
