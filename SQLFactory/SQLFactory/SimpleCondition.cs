using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class SimpleCondition : Condition
    {
        public static Boolean EmbedParametersDefault = false;

        public SimpleCondition()
        {
            LinkOperator = ConditionLinkOperator.loAND;
            UseRaw = false;
            EmbedParameter = EmbedParametersDefault;
        }

        private String expression = "";
        public String Expression
        {
            get
            {
                return expression;
            }
            set
            {
                this.expression = this.CleanUp(value);
            }
        }

        private Object literalValue = null;
        private Boolean hasLiteralValue = false;
        public Object LiteralValue { 
            get {
                return literalValue;
            }
            set {
                hasLiteralValue = true;
                literalValue = value;
            }
        }
        public Boolean UseRaw { get; set; }
        public Boolean EmbedParameter { get; set; }

                public override Boolean IsMatch(String key)
        {
            String s1 = Regex.Replace(key, @"[\x01-\x1F\x28\x29\x5B\x5D]", "").Trim();
            String s2 = Regex.Replace(Expression, @"[\x01-\x1F\x28\x29\x5B\x5D]", "").Trim();
  
            Boolean result = Regex.Replace(s1, " ", "").Equals(Regex.Replace(s2, " ", ""), StringComparison.OrdinalIgnoreCase);
            
            if (!result) {
                int p = s2.IndexOf('=');
                if (p == -1) 
                    p = s2.IndexOf('<');
                if (p == -1) 
                    p = s2.IndexOf('>');
                if (p == -1)
                    p = s2.IndexOf(" IS ", StringComparison.OrdinalIgnoreCase);
                if (p == -1) 
                    p = s2.IndexOf(" IN ", StringComparison.OrdinalIgnoreCase);
                if (p > -1)
                {
                    s2 =s2.Substring(0, p).Trim();
                    result = s1.Equals(s2, StringComparison.OrdinalIgnoreCase);

                }
            }
            return result;

        }

        public String LiteralAsText()
        {
            if (this.hasLiteralValue)
            {
                if (UseRaw && (literalValue is String))
                    return (String)literalValue;
                else 
                    return SQLFactory.ValueToSQLLiteralValue(literalValue);
            }
            else
                return "";
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (this.IsNegative)
                sql.Append("(NOT ");
            Boolean addParens = (!this.Expression.StartsWith("("));
            if (addParens)
                sql.Append('(');
            if (hasLiteralValue) {
                sql.Append(Expression.Replace(":", this.LiteralAsText()));
            }
            else if (EmbedParameter && (this.Parameters.Count() > 0)) {
                sql.Append(Expression.Replace(":", SQLFactory.ValueToSQLLiteralValue(Parameters.ElementAt(0).Value)));
                this.Parameters.Clear();
            }
            else
            {
                sql.Append(Expression);
            }

            if (addParens)
                sql.Append(')');
            else
                sql.Append(' ');

            if (this.IsNegative)
                sql.Append(')');

            base.BuildSQL(sql, parameters, indent);
        }
    }
}
