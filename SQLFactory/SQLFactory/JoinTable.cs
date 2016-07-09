using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class JoinTable : FromTable
    {
        private ConditionList joinOn;
        public virtual ConditionList JoinOn {
            get
            {
                if (this.joinOn == null)
                    this.joinOn = new ConditionList();
                return this.joinOn;
            }
            set
            {
                this.joinOn = value;
            }
        }
        public JoinType JoinType { get; set; }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            InternalBuildJoinType(sql, indent);

            InternalBuildFromSoure(sql, parameters, indent);

            InternalBuildOnLink(sql, parameters, indent);
        }

        protected void InternalBuildJoinType(StringBuilder sql, String indent)
        {
            if (JoinType == JoinType.jtLeftJoin)
                sql.Append("LEFT OUTER JOIN ");
            else
                sql.Append("JOIN ");

        }

        protected void InternalBuildOnLink(StringBuilder sql, ParameterList parameters, string indent = "")
        {

            if (JoinOn.Count() > 1)
            {
                sql.Append("\n");
                sql.Append(indent);
                sql.Append(SQLFactory.STD_INDENT);
                sql.Append(' ');
            }

            sql.Append(" ON ");
            JoinOn.BuildSQL(sql, parameters, indent + SQLFactory.STD_INDENT);
        }

    }

    public class JoinSubSelect : JoinTable
    {
        
    }

    public class JoinTableList : SQLElementList<JoinTable>
    {
        //protected virtual JoinTable CreateJoinTable()
        //{
        //    return new JoinTable();
        //}

        public JoinSubSelect AddSubselect(String joinToAlias, String joinOnCondition = "", JoinType joinType = JoinType.jtJoin)
        {
            JoinSubSelect result = new JoinSubSelect();
            result.TableAlias = joinToAlias;
            if (!String.IsNullOrEmpty(joinOnCondition))
                result.JoinOn.Add(joinOnCondition);
            result.JoinType = joinType;

            return result;
        }
 
        public JoinSubSelect Add(SQLSelectFactory subSelect, String joinToAlias, String joinOnCondition, JoinType joinType = JoinType.jtJoin)
        {
            JoinSubSelect result = new JoinSubSelect();
            result.SubSelect = subSelect;
            result.TableAlias = joinToAlias;
            if (!String.IsNullOrEmpty(joinOnCondition))
                result.JoinOn.Add(joinOnCondition);
            result.JoinType = joinType;

            return result;
        }

        public JoinTable Add(String joinTableExpression, String joinOnCondition, JoinType joinType = JoinType.jtJoin)
        {
            String tmpName;
            String tmpAlias;
            String tmpSchema;
            SQLFactory.ParseColumnInfo(joinTableExpression, out tmpSchema, out tmpName, out tmpAlias);

            return Add(tmpName, tmpAlias, joinOnCondition, joinType);
        }

        public JoinTable Add(String joinTableName, String joinToAlias, String joinOnCondition, JoinType joinType = JoinType.jtJoin) {
            JoinTable result = new JoinTable();
            result.TableName = joinTableName;
            result.TableAlias = joinToAlias;
            if (!String.IsNullOrEmpty(joinOnCondition))
                result.JoinOn.Add(joinOnCondition);
            result.JoinType = joinType;

            return result;
        }

        public void Add(String[] joinToInfo) {
            foreach(String joinInfo in joinToInfo) {
                int p=0;

                JoinType joinType = JoinType.jtJoin;

                String tmpTableName = joinInfo.ParseNext(ref p, ", ", "'", "\"\"[]");
                String tmpAlias  = joinInfo.ParseNext(ref p, ", ", "'", "\"\"[]");
                String tmpExpr = joinInfo.ParseNext(ref p, ", ", "'", "\"\"[]");
                
                if ("LEFT".Equals(tmpTableName, StringComparison.OrdinalIgnoreCase)) {
                    joinType = JoinType.jtLeftJoin;
                    tmpTableName = tmpAlias;
                    tmpAlias = tmpExpr;
                    tmpExpr = joinInfo.ParseNext(ref p, ", ", "'", "\"\"[]");
                }
                else if ("JOIN".Equals(tmpTableName, StringComparison.OrdinalIgnoreCase)) {
                    tmpTableName = tmpAlias;
                    tmpAlias = tmpExpr;
                    tmpExpr = joinInfo.ParseNext(ref p, ", ", "'", "\"\"[]");
                }
                if ((String.IsNullOrEmpty(tmpExpr)) && (!String.IsNullOrEmpty(tmpAlias))) {
                    tmpExpr = tmpAlias;
                    tmpAlias = "";
                }
                Add(tmpTableName, tmpAlias, tmpExpr, joinType);
            }
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            foreach (JoinTable joinTable in this)
            {
                sql.Append('\n');
                sql.Append(indent);
                joinTable.BuildSQL(sql, parameters, indent);
            }   
        }
    }
}
