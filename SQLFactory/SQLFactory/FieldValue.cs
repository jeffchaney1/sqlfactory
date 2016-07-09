using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class FieldValue : Column
    {
        //protected FieldValue(SQLElementList Owner) : base(Owner) { }
        public FieldValue() {
            MaxLength = -1;
            OutputUTC = FieldValue.DefaultUseUTC;
        }


        private Object literalValue = null;

        public Object LiteralValue
        {
            get
            {
                return literalValue;
            }
            set
            {
                if (value is DateTime) 
                {
                    //if (((DateTime)value).IsDaylightSavingTime())
                        literalValue = new DateTimeOffset((DateTime)value);
                    //else
                    //    literalValue = new DateTimeOffset((DateTime)value, DateTimeOffset.Now.Offset); 
                }
                else
                    literalValue = value;
                isLiteral = true;
                useRaw = false;
                this.Parameters.Clear();
            }
        }

        //protected DateTimeOffset handleDateTime(object value)
        //{
        //    if (value is DateTimeOffset) 
        //        return (DateTimeOffset)value;
        //    else 
        //    if (OutputUTC)
        //    {
        //        DateTime
        //    }
        //    else
        //        return Convert.ToDateTime(value);
        //}

        public void ClearLiteral()
        {
            isLiteral = false;
            literalValue = null;
        }
          
        private bool isLiteral = false;
        public bool IsLiteral
        {
            get
            {
                return isLiteral;
            }
            //set
            //{
            //    isLiteral = value;
            //}
        }
        private bool useRaw = false;
        public bool UseRaw
        {
            get
            {
                return useRaw;
            }
            set
            {
                if (value && this.IsLiteral && (literalValue is String))
                    useRaw = true;
                else
                    useRaw = false;
            }
        }

        public bool IsParameter
        {
            get
            {
                return this.Parameters.Count() > 0;
            }
        }

        // Only used for String values
        public int MaxLength { get; set; }
        // Only used for DateTime values.  
        // When true it assumes the DateTime value is in the local TZ 
        //   and the value written to the SQL string is converted to UTC
        public bool OutputUTC { get; set; }

        // This can be set to true to treat all DateTimes as UTC
        //   rather than local DateTime
        public static bool DefaultUseUTC = false;




        public void BuildValue(StringBuilder sql, ParameterList parameters)
        {
            if (this.IsParameter)
            {
                if (   this.Parameters[0].Type.Equals(DataType.dtDateTime)
                    && (this.Parameters[0].Value == null))
                {
                    sql.Append("NULL");
                }
                else
                {
                    parameters.AddParameter(this.Parameters[0]);
                    if (   (this.MaxLength > 0) 
                        && this.Parameters[0].Type.Equals(DataType.dtString)
                        && (   (this.Parameters[0].Direction == ParameterDirection.pdInput)
                            || (this.Parameters[0].Direction == ParameterDirection.pdInputOutput)))
                    {
                        String ws = this.Parameters[0].Value.ToString();
                        ws = ws.Substring(0, MaxLength);
                        parameters[parameters.Count - 1].Value = ws;
                    }
                }
                sql.Append(SQLFactory.ParameterPlaceholder); 
            }
            else if (this.IsLiteral) 
            {
                if (this.UseRaw && (this.literalValue != null)) {
                    sql.Append(this.literalValue.ToString());
                }
                else if (  (this.literalValue == null) 
                        || this.literalValue.ToString().Equals("NULL", StringComparison.OrdinalIgnoreCase)) 
                {
                    sql.Append("NULL");
                }
                else if ((this.MaxLength > 0) && (this.LiteralValue is String)) {
                    String ws = this.LiteralValue.ToString();
                    sql.Append(SQLFactory.ValueToSQLLiteralValue(ws.Substring(0, this.MaxLength)));
                }
                else if ((this.LiteralValue is DateTimeOffset) && this.OutputUTC) {
                   sql.Append("'");
                   string val = ((DateTimeOffset)this.LiteralValue).ToString("yyyy-MM-ddTHH:mm:sszzz");
                   sql.Append(val);
                   sql.Append("'");
                }
                else {
                    sql.Append(SQLFactory.ValueToSQLLiteralValue(literalValue));
                } 

            }
            else
                throw new ESQLFactoryException("No insert value defined for " + this.ColumnName);
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, String indent)
        {
            sql.Append('[');
            sql.Append(ColumnName);
            sql.Append(']');
        }

        //public override void Assign(IOwnedElement source)
        //{
        //    base.Assign(source);
        //    if ((source != null) && (source is FieldValueDef))
        //    {
        //        FieldValueDef other = (FieldValueDef)source;
        //        if (other.IsLiteral)
        //        {
        //            this.LiteralValue = other.LiteralValue;
        //            if (other.UseRaw)
        //                this.UseRaw = true;
        //        }
        //        else
        //            this.ClearLiteral();
        //    }
        //}

    }

    public class FieldValueList : CustomColumnList<FieldValue> 
    {
        //protected FieldValueList(IOwnedElement Owner) : base(Owner) { }


        public FieldValue Insert(int columnPos, String columnName)
        {
            FieldValue result = new FieldValue();
            result.ColumnName = columnName;
            this.Insert(columnPos, result);
            return result;
        }

        public FieldValue Add(String columnName)
        {
            return this.Insert(this.Count, columnName);
        }


        public FieldValue Insert(int columnPos, String columnName, bool literalValue)
        {
            FieldValue result = Insert(columnPos, columnName);
            result.LiteralValue = literalValue;
            return result;
        }
        public FieldValue Add(String columnName, bool literalValue)
        {
            return Insert(this.Count, columnName, literalValue);
        }

        public FieldValue Insert(int columnPos, String columnName, Int64 literalValue)
        {
            FieldValue result = Insert(columnPos, columnName);
            result.LiteralValue = literalValue;
            return result;
        }

        public FieldValue Add(String columnName, Int64 literalValue) {
            return Insert(this.Count, columnName, literalValue);
        }

        public FieldValue Insert(int columnPos, String columnName, Double literalValue)
        {
            FieldValue result = Insert(columnPos, columnName);
            result.LiteralValue = literalValue;
            return result;
        }
        public FieldValue Add(String columnName, Double literalValue) {
            return Insert(this.Count, columnName, literalValue);
        }

        public FieldValue Insert(int columnPos, String columnName, String literalValue, bool useRaw=false)
        {
            FieldValue result = Insert(columnPos, columnName);
            result.LiteralValue = literalValue;
            result.UseRaw = useRaw;
            return result;
        }
        public FieldValue Add(String columnName, String literalValue, bool useRaw=false) {
            return Insert(this.Count, columnName, literalValue, useRaw);
        }

        public FieldValue Insert(int columnPos, String columnName, String literalValue, int maxLength)
        {
            FieldValue result = Insert(columnPos, columnName);
            result.LiteralValue = literalValue;
            result.MaxLength = maxLength;
            return result;
        }
        public FieldValue Add(String columnName, String literalValue, int maxLength) {
            return Insert(this.Count, columnName, literalValue, maxLength);
        }

        public FieldValue Insert(int columnPos, String columnName, DateTime literalValue)
        {
            FieldValue result = Insert(columnPos, columnName);
            result.LiteralValue = literalValue;
            return result;
        }
        public FieldValue Add(String columnName, DateTime literalValue) {
            return Insert(this.Count, columnName, literalValue);
        }

        public void Insert(int columnPos, String[] columnNames)
        {
            Insert(columnPos, columnNames, null);
        }
        public void Add(String[] columnNames)
        {
            Insert(this.Count, columnNames);
        }

        public void Insert(int columnPos, String[] columnNames, Object[] literalValues)
        {
            for(int idx = 0;idx < columnNames.Length;idx++)
            {
                FieldValue newField = Insert(columnPos + idx, columnNames[idx]);
                if ((literalValues != null) && (literalValues.Length > idx))
                    newField.LiteralValue = literalValues[idx];
            }
        }
        public void Add(String[] columnNames, Object[] literalValues)
        {
            Insert(this.Count, columnNames, literalValues);
        }

        public bool BuildValuesList(StringBuilder sql, ParameterList parameters, String indent)
        {
            bool result = false;
            if (this.Count > 0)
            {
                if (this.First().IsParameter || this.First().IsLiteral)
                {
                    result = true;
                    sql.Append("VALUES (");
                    this.First().BuildValue(sql, parameters);
                    int columnCount = 1;
                    foreach (FieldValue column in this.Skip(1))
                    {
                        sql.Append(", ");
                        column.BuildValue(sql, parameters);
                        if (columnCount % 4 == 0)
                            sql.Append('\n');
                    }
                    sql.Append(')');
                }
            }
            return result;
        }

    }
}
