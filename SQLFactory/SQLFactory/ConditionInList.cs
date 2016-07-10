using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class ConditionInList : Condition
    {
        private String valueExpression = "";
        public String ValueExpression {
            get
            {
                return valueExpression;
            }
            set
            {
                valueExpression = value;
                AddDelimiters = SQLFactory.IsIdentOnly(valueExpression);
            }
        }
        public bool AddDelimiters { get; set; }
        private List<String> rawValues = new List<String>();

        public ConditionInList AddValues(Object[] values)
        {
            if (values != null) {
                foreach (Object value in values)
                {
                    if (value != null)
                        rawValues.Add(SQLFactory.ValueToSQLLiteralValue(value));
                }
            }
            return this;
        }

        public ConditionInList AddRawValues(String[] values)
        {
            if (values != null)
            {
                rawValues.Concat(values);
            }
            return this;
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if ((rawValues.Count() > 0) && !String.IsNullOrEmpty(ValueExpression))
            {
                if (IsNegative)
                    sql.Append("(NOT ");
                sql.Append('(');
                if (AddDelimiters)
                    sql.Append('[');
                sql.Append(ValueExpression);
                if (AddDelimiters)
                    sql.Append(']');
                sql.Append(" IN (");
                sql.Append(rawValues.ElementAt(0));
                foreach (String value in rawValues.Skip(1))
                {
                    sql.Append(", ");
                    sql.Append(value);
                }
                sql.Append(") ) ");
                if (IsNegative) 
                    sql.Append(')');

            }
        }

    }
}
