using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public abstract class BaseSQLUpdateFactory : SQLConditionalModifyFactory
    {
        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if ((!GetAllowNoConditions()) && (GetWhere().Count == 0))
                throw new ESQLUpdateNoConditions("No conditions on which records are to be updated have been defined.");
            if (GetColumns().Count == 0)
                throw new ESQLUpdateNoColumns("No columns have been defined for updating.");

            sql.Append("UPDATE ");

            InternalBuildModifyTable(sql, parameters, indent);

            InternalBuildUpdateColumns(sql, parameters, indent);

            InternalBuildWhereClause(sql, parameters, indent);
        }

        protected virtual Boolean InternalIncludeColumn(FieldValue column)
        {
            return true;
        }

        protected void InternalBuildUpdateColumns(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (GetColumns().Count() > 0)
            {
                sql.Append('\n');
                sql.Append(indent);

                sql.Append("SET ");
                var first = true;

                foreach (var col in GetColumns())
                {
                    if (InternalIncludeColumn(col))
                    {
                        if (!first)
                        {
                            sql.Append(",\n");
                            sql.Append(indent);
                            sql.Append("    ");
                            first = false;
                        }
                        col.BuildSQL(sql, null, "");
                        sql.Append(" = ");
                        col.BuildValue(sql, parameters);
                    }
                }
            }
        }
    }

    public class SQLUpdateFactory : BaseSQLUpdateFactory
    {
        public Table UpdateTable { get { return GetTable(); } }

        public FieldValueList Columns { get { return GetColumns(); } }

        public Boolean AllowNoConditions { get { return GetAllowNoConditions(); } set { SetAllowNoConditions(value); } }
        public ConditionList Where { get { return GetWhere(); } }
    }

    public class SQLUpdateOrInsertFactory : BaseSQLUpdateFactory
    {
        public SQLUpdateOrInsertFactory()
        {
            UpdateOnlyIfDifferent = true;
        }

        // These two properties hold the same value.  They just reflect the two 
        //   ways of thinking about the table
        public Table UpdateTable { get { return GetTable(); } } // same as IntoTable
        public Table IntoTable { get { return GetTable(); } } // same as UpdateTable

        public FieldValueList Columns { get { return GetColumns(); } }

        private List<String> keyColumns = new List<String>();
        public List<String> KeyColumns { get { return this.keyColumns; } }
        public void AddKeyColumns(params String[] keyColumnNames)
        {
            foreach (String keyName in keyColumnNames)
            {
                KeyColumns.Add(keyName);
            }
        }
        //public Boolean AllowNoConditions { get { return GetAllowNoConditions(); } set { SetAllowNoConditions(value); } }
        public Boolean UpdateOnlyIfDifferent { get; set; }
        public Boolean InsertOnly { get; set; }

        protected override Boolean InternalIncludeColumn(FieldValue column) {
            return KeyColumns.Contains(column.ColumnName);
        }

        private void AddWhereForKeys(ConditionList conditionList)
        {
            foreach (String keyName in KeyColumns)
            {
                var column = Columns.Where(c => c.Name == keyName).FirstOrDefault();
                if (column == null)
                    throw new ESQLFactoryException("Key Column, '" + keyName + "' was not found in Columns.");
                conditionList.Add(column);
            };
        }

        private void AddWhereIfDifferent(ConditionList conditionList)
        {
            ConditionGroup orGroup = new ConditionGroup();
            orGroup.LinkOperator = ConditionLinkOperator.loOR;
            foreach (var column in Columns)
            {
                if (!KeyColumns.Contains(column.Name))
                    conditionList.Add(column, false);
            }
        }

        protected override void InternalBuildWhereClause(StringBuilder sql, ParameterList parameters, string indent = "") {
            GetWhere().Clear();
            AddWhereForKeys(GetWhere());
            if (this.UpdateOnlyIfDifferent)
                AddWhereIfDifferent(GetWhere());
            base.InternalBuildWhereClause(sql, parameters, indent);

        //    var firstCondition = true;
        //    foreach (String keyName in KeyColumns) {
        //        var column = Columns.Where(c => c.Name == keyName).FirstOrDefault();

        //        sql.Append('\n');
        //        sql.Append(indent);
        //        if (firstCondition)
        //            sql.Append("WHERE ");
        //        else
        //            sql.Append(" AND ");
        //        sql.Append("([");
        //        sql.Append(column.Name);
        //        sql.Append("] = ");
        //        column.BuildValue(sql, parameters);
        //        sql.Append(')');

        //        firstCondition = false;
        //    }

        //    // Only update only if one OR more of the Non-Key Values are different
        //    if (this.UpdateOnlyIfDifferent) {
        //        var firstOR = true;
        //        foreach (var column in Columns) {
        //            if (!KeyColumns.Contains(column.Name))
        //            {
        //                if (firstOR) {
        //                    if (firstCondition) {
        //                        sql.Append('\n');
        //                        sql.Append(indent);
        //                        sql.Append("WHERE (");
        //                    }
        //                    else
        //                        sql.Append(" AND (");
        //                }
        //                else {
        //                    sql.Append(indent);
        //                    sql.Append(" OR ");
        //                }

        //                sql.Append("([");
        //                sql.Append(column.Name);
        //                sql.Append("] <> ");
        //                column.BuildValue(sql, parameters);
        //                sql.Append(')');
        //                firstCondition = false;
        //                firstOR = false;
        //            }
        //        }

        //        if (!firstOR)
        //            sql.Append(')');

        //    }
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (!GetAllowNoConditions() && (GetWhere().Count == 0) && (KeyColumns.Count == 0) )
                throw new ESQLUpdateNoConditions("No conditions on which records are to be updated have been defined.");
            if (Columns.Count == 0)
              throw new ESQLUpdateNoColumns("No columns have been defined for updating.");

            sql.Append(indent);
            if (InsertOnly)
                sql.Append("IF NOT EXISTS (");
            else
                sql.Append("IF EXISTS (");
                
            var selectSQL = new SQLSelectFactory();
            selectSQL.FromTable.ServerName = UpdateTable.ServerName;
            selectSQL.FromTable.DatabaseName = UpdateTable.DatabaseName;
            selectSQL.FromTable.TableSchema = UpdateTable.TableSchema;
            selectSQL.FromTable.TableAlias = UpdateTable.TableAlias;
            selectSQL.FromTable.TableName = UpdateTable.TableName;

            selectSQL.TopCount = 1;
            AddWhereForKeys(selectSQL.Where);

            selectSQL.BuildSQL(sql, parameters, indent + "           ");

            sql.Append(") \n");

            if (!InsertOnly) {
                var SvAllow = GetAllowNoConditions();
                try {
                    SetAllowNoConditions(true);
                    // Build the UPDATE
                    base.BuildSQL(sql, parameters, indent +"    ");
                } finally {
                    SetAllowNoConditions(SvAllow);
                }
                sql.Append('\n');
                sql.Append(indent);
                sql.Append("ELSE\n");
            }

            var insertSQL = new SQLInsertFactory();
            insertSQL.IntoTable.ServerName = UpdateTable.ServerName;
            insertSQL.IntoTable.DatabaseName = UpdateTable.DatabaseName;
            insertSQL.IntoTable.TableSchema = UpdateTable.TableSchema;
            insertSQL.IntoTable.TableAlias = UpdateTable.TableAlias;
            insertSQL.IntoTable.TableName = UpdateTable.TableName;
            insertSQL.BuildSQL(sql, parameters, indent + "    ");
        }
    }
}
