using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class ConditionInSelect : Condition
    {
        public String ValueExpression { get; set; }

        private SQLSelectFactory subSelect = null;
        public SQLSelectFactory SubSelect {
            get
            {
                if (this.subSelect == null)
                    this.subSelect = new SQLSelectFactory();
                return this.subSelect;
            }
            set
            {
                this.subSelect = value;
            }
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (IsNegative)
                sql.Append("( NOT ");
            sql.Append('(');
            sql.Append(this.ValueExpression);
            sql.Append(" IN (\n");
            SubSelect.BuildSQL(sql, parameters, indent + SQLFactory.STD_INDENT);
            sql.Append(") )");
            if (IsNegative)
                sql.Append(')');
        }
    }
}
