using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class Column : ParameteredElement
    {
        //protected Column(SQLElementList Owner) : base(Owner) { }

        private String tableName;
        public String TableName { get { return tableName; } set { tableName = value; } }
        private String columnName;
        public String ColumnName 
        { get {return columnName;} 
          set {
              String tmpTable, tmpAlias;

              SQLFactory.ParseColumnInfo(value, out tmpTable, out columnName, out tmpAlias);

              if (!String.IsNullOrEmpty(tmpTable))
                  tableName = tmpTable;

              AddDelimiters = SQLFactory.IsIdentifier(columnName);
          } 
        }

        public bool AddDelimiters { get; set; }

        public override bool IsMatch(String key)
        {
            return this.ColumnName.Trim().Equals(key.Trim(), StringComparison.OrdinalIgnoreCase);
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (!String.IsNullOrEmpty(tableName))
            {
                if (AddDelimiters)
                    sql.Append('[');
                sql.Append(tableName);
                if (AddDelimiters)
                    sql.Append(']');

                sql.Append('.');
            }

            if (AddDelimiters)
                sql.Append('[');
            sql.Append(columnName);
            if (AddDelimiters)
                sql.Append(']');

        }

        //public override void Assign(IOwnedElement Source)
        //{
        //    base.Assign(Source);
        //    if ((Source != null) && (Source is Column))
        //    {
        //        Column other = (Column)Source;
        //        this.TableName = other.TableName;
        //        this.ColumnName = other.ColumnName;
        //        this.AddDelimiters = other.AddDelimiters;
        //    }
        //}
    }

    public class CustomColumnList<TColumn> : SQLElementList<TColumn> where TColumn : Column
    {
        //protected CustomColumnList(IOwnedElement Owner) : base(Owner) { }
        private int columnsPerRow = 4;
        public int ColumnsPerRow { get { return columnsPerRow; } set { columnsPerRow = value; } }
        //public Column Field(int idx)
        //{
        //    return (Column)this.elements.ElementAt(idx);
        //}
        private Dictionary<String, TColumn> columnsByName = new Dictionary<String, TColumn>();

        public override void Insert(int index, TColumn value)
        {
            base.Insert(index, value);
            this.columnsByName.Add(value.ColumnName, value);
        }

        public TColumn Column(String key)
        {
            return (TColumn)this.columnsByName[key];
        }

        public void Remove(String columnName)
        {
            TColumn column = Column(columnName);
            if (column != null) {
                this.columnsByName.Remove(columnName);
                this.Remove(column);
            }
        }




        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (this.Count == 0)
                return;

            int fieldsWithoutBreak = 0;

            this.First().BuildSQL(sql, parameters, indent);

            foreach (SQLElementItem element in this.Skip(1))
            {
                sql.Append(", ");
                if (fieldsWithoutBreak > this.ColumnsPerRow)
                {
                    sql.Append(" \n");
                    sql.Append(indent);
                    sql.Append(SQLFactory.STD_INDENT);
                    fieldsWithoutBreak = 0;
                }

                int p = sql.Length;
                element.BuildSQL(sql, parameters, indent);
                fieldsWithoutBreak += 1;

                if (sql.ToString().IndexOf("\n", p + 1) > -1)
                {
                    fieldsWithoutBreak = 0;
                }
            }

        }

    }

    public class ColumnList : CustomColumnList<Column>
    {
        //protected ColumnList(IOwnedElement Owner) : base(Owner) { }

        //public void Add(Column field) {
        //    this.InsertItem(field);
        //}
    }

}
