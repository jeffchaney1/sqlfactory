using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class Table : ParameteredElement
    {
        //protected Table(SQLElementList Owner) : base(Owner) { }

        private String serverName = "";
        public virtual String ServerName { get { return serverName; } set { serverName = value; } }
        private String databaseName = "";
        public virtual String DatabaseName { get { return databaseName; } set { databaseName = value; } }
        private String tableSchema = "";
        public virtual String TableSchema { get { return tableSchema; } set { tableSchema = value; } }

        private String tableName="";
        public virtual String TableName
        {
            get { return tableName; } 
            set {
                String tmpAlias, tmpSchema;

                SQLFactory.ParseColumnInfo(value, out tmpSchema, out tableName, out tmpAlias);

                if (!String.IsNullOrEmpty(tmpAlias)) 
                    TableAlias = tmpAlias;
                  if (String.IsNullOrEmpty(TableAlias) )
                    TableAlias = TableName;
                  AddDelimiters = SQLFactory.IsIdentifier(tableName);

                  if (!String.IsNullOrEmpty(tmpSchema))
                  {
                      if (tmpSchema.Contains('.'))
                      {
                          tmpSchema = tmpSchema.ParsePrev(out tmpAlias, ".");
                          TableSchema = tmpAlias;
                          tmpSchema = tmpSchema.ParsePrev(out tmpAlias, ".");
                          DatabaseName = tmpAlias;
                          ServerName  = tmpSchema;
                      }
                      else 
                        TableSchema = tmpSchema;
                  }

            } 
        }
        private String tableAlias="";
        public String TableAlias 
        { 
            get {
                if (String.IsNullOrEmpty(tableAlias))
                    return TableName;
                else
                    return tableAlias;
            }
 
            set {
                tableAlias = value;
            } 
        }

        private bool addDelimiters = true;
        public bool AddDelimiters { get { return addDelimiters; } set { addDelimiters = value; } }

        public override Boolean IsMatch(String key)
        {
            if (String.IsNullOrEmpty(key))
                return false;
            else if (String.IsNullOrEmpty(TableAlias))
            {
                if (String.IsNullOrEmpty(TableName))
                    return false;
                else
                    return TableName.Trim().ToUpper().Equals(key.Trim().ToUpper());
            }
            else
                return TableAlias.Trim().ToUpper().Equals(key.Trim().ToUpper());
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            InternalBuildFullTableIdentifier(sql, indent);
            InternalBuildParameters(parameters);
        }

        protected virtual void InternalBuildFullTableIdentifier(StringBuilder sql, string indent)
        {
            bool periodRequired = false;
            if (!String.IsNullOrEmpty(ServerName))
            {
                InternalBuildTableServer(sql, indent);
                periodRequired = true;
            }
            if (periodRequired)
                sql.Append('.');

            if (!String.IsNullOrEmpty(DatabaseName))
            {
                InternalBuildTableDatabase(sql, indent);
                periodRequired = true;
            }
            if (periodRequired)
                sql.Append('.');

            if (!String.IsNullOrEmpty(TableSchema))
            {
                InternalBuildTableSchema(sql, indent);
                periodRequired = true;
            }
            if (periodRequired)
                sql.Append('.');

            InternalBuildTableName(sql, indent);

            if ((!String.IsNullOrEmpty(tableAlias)) && (!TableAlias.Equals(TableName)))
            {
                sql.Append(" ");
                InternalBuildTableAlias(sql, indent);
            }
        }

        protected void InternalBuildTableServer(StringBuilder sql, string indent)
        {
            if (!String.IsNullOrEmpty(ServerName))
            {
                if (this.AddDelimiters && !this.ServerName.StartsWith("["))
                    sql.Append('[');

                sql.Append(this.ServerName);

                if (this.AddDelimiters && !this.ServerName.StartsWith("["))
                    sql.Append(']');
            
            }
        }

        protected void InternalBuildTableDatabase(StringBuilder sql, string indent)
        {
            if (!String.IsNullOrEmpty(DatabaseName))
            {
                if (this.AddDelimiters && !this.DatabaseName.StartsWith("["))
                    sql.Append('[');

                sql.Append(this.DatabaseName);

                if (this.AddDelimiters && !this.DatabaseName.StartsWith("["))
                    sql.Append(']');

            }
        }

        protected void InternalBuildTableSchema(StringBuilder sql, string indent)
        {
            if (!String.IsNullOrEmpty(TableSchema))
            {
                if (this.AddDelimiters && !this.TableSchema.StartsWith("["))
                    sql.Append('[');

                sql.Append(this.TableSchema);

                if (this.AddDelimiters && !this.TableSchema.StartsWith("["))
                    sql.Append(']');

            }
        }

        protected void InternalBuildTableName(StringBuilder sql, string indent)
        {
            if (!String.IsNullOrEmpty(TableName))
            {
                if (this.AddDelimiters && !this.TableName.StartsWith("["))
                    sql.Append('[');

                sql.Append(this.TableName);

                if (this.AddDelimiters && !this.TableName.StartsWith("["))
                    sql.Append(']');

            }
        }

        protected void InternalBuildTableAlias(StringBuilder sql, string indent)
        {
            if (!String.IsNullOrEmpty(TableAlias))
            {
                if (this.AddDelimiters && !this.TableAlias.StartsWith("["))
                    sql.Append('[');

                sql.Append(this.TableAlias);

                if (this.AddDelimiters && !this.TableAlias.StartsWith("["))
                    sql.Append(']');

            }
            
        }

    }
}
