using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class FromTable : Table
    {
        private SQLSelectFactory subSelect = null;
        public SQLSelectFactory SubSelect
        {
            get
            {
                if (subSelect == null)
                {
                    if (String.IsNullOrEmpty(TableAlias))
                    {
                        TableAlias = TableName;
                        TableName = "";
                    }
                    subSelect = InternalCreateSQLSelectFactory();
                }
                return subSelect;
            }
            set
            {
                if (value != null)
                {
                    this.TableName = "";
                    this.TableSchema = "";
                }
                this.subSelect = value;
            }
        }

        public bool IsSubSelect { get { return this.subSelect != null; } }


        protected virtual SQLSelectFactory InternalCreateSQLSelectFactory()
        {
            return new SQLSelectFactory();
        }

        private String sqlHint;
        public String SQLHint
        {
            get
            {
                return this.sqlHint;
            }
            set
            {
                if ((value != null) && "WITH".Equals(value.Substring(0, 4), StringComparison.OrdinalIgnoreCase))
                {
                    int p = value.IndexOf("WITH");
                    this.sqlHint = value.Substring(p);
                    if (this.sqlHint.StartsWith("("))
                        this.sqlHint = this.sqlHint.Substring(1).Trim();
                    if (this.sqlHint.EndsWith(")"))
                        this.sqlHint = this.sqlHint.Substring(0, this.sqlHint.Length - 1);
                }
                else
                {
                    this.sqlHint = value;
                }
            }
        }

        public override String TableSchema
        {
            get
            {
                return base.TableSchema;
            }
            set
            {
                base.TableSchema = value;
                SubSelect = null;
            }
        }

        public override string TableName
        {
            get
            {
                return base.TableName;
            }
            set
            {
                base.TableName = value;
                SubSelect = null;
            }
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            InternalBuildFromSoure(sql, parameters, indent);
        }

        protected virtual void InternalBuildFromSoure(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (this.IsSubSelect)
            {
                InternalBuildSubSelect(sql, parameters, indent);
            }
            else
            {
                InternalBuildFullTableIdentitifer(sql, indent);
                InternalBuildParameters(parameters);
            }
        }

        protected virtual void InternalBuildSubSelect(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            sql.Append("(\n");
            sql.Append(indent);
            SubSelect.BuildSQL(sql, parameters, indent + SQLFactory.STD_INDENT);
            sql.Append('\n');
            sql.Append(indent);
            sql.Append(") ");
            if (this.AddDelimiters)
                sql.Append('[');
            if (!String.IsNullOrEmpty(this.TableAlias))
                sql.Append(TableAlias);
            else if (!String.IsNullOrEmpty(this.TableName))
                sql.Append(TableName);
            else
                sql.Append(this.MyIdent("JoinAlias", !AddDelimiters));

            if (AddDelimiters)
                sql.Append(']');

        }

        protected void InternalBuildFullTableIdentitifer(StringBuilder sql, string indent = "")
        {
            base.InternalBuildFullTableIdentifier(sql, indent);

            if (!String.IsNullOrEmpty(this.SQLHint))
            {
                sql.Append("WITH (");
                sql.Append(this.SQLHint);
                sql.Append(')');
            }
        }

    }
}
