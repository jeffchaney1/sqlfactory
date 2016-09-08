using Library.SQLFactory.Builders;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class Condition : ParameteredElement
    {
        public Condition()
        {
            this.LinkOperator = ConditionLinkOperator.loAND;
            this.IsNegative = false;
        }

        public ConditionLinkOperator LinkOperator { get; set; }
        public Boolean IsNegative { get; set; }

        
    }

    public class ConditionList : SQLElementList<Condition>, ISQLElement
    {
        public ConditionLinkOperator DefaultLink { get; set; }
        
        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (this.Count() > 0) {
                this.ElementAt(0).BuildSQL(sql, parameters, indent);

                foreach(Condition condition in this.Skip(1)) {
                    sql.Append('\n');
                    sql.Append(indent);
                    sql.Append(SQLFactory.LinkOperatorToSQL(condition.LinkOperator));
                    sql.Append(' ');
                    condition.BuildSQL(sql, parameters, indent);
                }
            }
        }

        
        public SimpleCondition Add(String expression)
        {
            return this.Add(expression, SQLFactory.UNDEFINED);
        }

        public SimpleCondition Add(String expression, Object value, Boolean useRaw=false)
        {
            SimpleCondition result = new SimpleCondition();
            result.LinkOperator = this.DefaultLink;

            // Does the expression already contain brackets?
            bool addBrackets = (Regex.Replace(expression, @"[^\x2E\x5B\x5D]", "").Count() == 0);  
            // This does not handle identifiers where there are non-identifier characters between
            bool identOnly = SQLFactory.IsIdentOnly(expression);

            if (identOnly) {
                if (addBrackets) 
                    result.Expression = "[" + expression + "] = :";
                else
                    result.Expression = expression + " = :";
            }
            else
                result.Expression = expression;

            if (!SQLFactory.UNDEFINED.Equals(value))
            {
                result.LiteralValue = value;
                result.UseRaw = useRaw;
            }
            this.Add(result);

            return result;
        }

        public SimpleCondition Add(FieldValue column, Boolean notNegative=true)
        {
            SimpleCondition result = new SimpleCondition();
            result.LinkOperator = this.DefaultLink;
            if (   (column.IsLiteral && (column.LiteralValue == null))
                || (column.IsParameter && (column.Parameters.First() == null)))
            {
                result.Expression = "[" + column.Name + "] IS " + (notNegative ? "": "NOT ")+ "NULL";
            }
            else if (column.IsParameter)
            {
                result.Expression = "[" + column.Name + "] = :";
                result.Parameters.AddParameters(column.Parameters);
            }
            else
            {
                StringBuilder sql = new StringBuilder();
                column.BuildValue(sql, null); 

                result.Expression = "[" + column.Name + "] = " + sql.ToString();
            }

            return result;
        }

        public ConditionList Or(Action<ConditionList> conditionBuilder)
        {
            ConditionList result = new ConditionList();
            this.AddGroup(ConditionLinkOperator.loOR)
            return this;
        }

        public ConditionList Add(String[] fields, Object[] values = null)
        {
            int valueIdx=-1;
            Object value = null;
            foreach(String expression in fields) {
                if ((expression.Contains(':') || SQLFactory.IsIdentOnly(expression))
                  && (values != null) && (valueIdx < values.Count())) 
                {
                    valueIdx++;
                    value = values[valueIdx];
                }
                else
                    value = SQLFactory.UNDEFINED;

                this.Add(expression, value);

            }
            return this;
        }

        public ConditionGroup AddGroup(ConditionLinkOperator linkOperator)
        {
            return AddGroup(new String[]{}, null, linkOperator);
        }

        public ConditionGroup AddGroup(String[] expressions, ConditionLinkOperator linkOperator)
        {
            return AddGroup(expressions, null, linkOperator);
        }

        public ConditionGroup AddGroup(String[] expressions, Object[] values, ConditionLinkOperator linkOperator)
        {
            ConditionGroup result = new ConditionGroup();
            result.LinkOperator = this.DefaultLink;
            result.Conditions.DefaultLink = linkOperator;
            
            if (expressions != null)
                result.Conditions.Add(expressions, values);

            this.Add(result);
            return result;
        }

        public ConditionInList AddInList(String valueExpression, String[] values, Boolean useRaw = false)
        {
            ConditionInList result = new ConditionInList();
            result.LinkOperator = this.DefaultLink;
            result.ValueExpression = valueExpression;
            if (useRaw)
                result.AddRawValues(values);
            else
                result.AddValues(values);
            this.Add(result);
            return result;
        }

        public ConditionInSelect AddInSelect(String valueExpression, SQLSelectFactory subSelect=null) {
            ConditionInSelect result = new ConditionInSelect();
            result.ValueExpression = valueExpression;
            result.SubSelect = subSelect;
            return result;
        }

    }


}
