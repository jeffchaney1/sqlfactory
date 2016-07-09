using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class SQLSelectFactory : SQLElementParent
    {
        private FromTable fromTable;
        public FromTable FromTable
        {
            get { 
                if (fromTable == null) 
                    fromTable = new FromTable();
                return fromTable; 
            }
            set { fromTable = value; }
        }

        private SelectColumnList columns;
        public SelectColumnList Columns
        {
            get { 
                if (columns == null) 
                    columns = new SelectColumnList();
                return this.columns; 
            }
            set { this.columns = value; }
        }

        private JoinTableList joinTo;
        public JoinTableList JoinTo
        {
            get { 
                if (joinTo == null) 
                    joinTo = new JoinTableList();
                return joinTo; 
            }
            set { joinTo = value; }
        }
        
        private ConditionList where;
        public ConditionList Where
        {
            get { 
                if (where == null) 
                    where = new ConditionList();
                return where; 
            }
            set { where = value; }
        }

        private ConditionList additionalConditions;
        public ConditionList AdditionalConditions
        {
            get {
                if (additionalConditions == null)
                    additionalConditions = new ConditionList();
                return additionalConditions; 
            }
            set { additionalConditions = value; }
        }
        
        
        private ConditionList having;
        public ConditionList Having
        {
            get { 
                if (having == null) 
                    having = new ConditionList();
                return having; 
            }
            set { having = value; }
        }
        
        private OrderByList orderBy;
        public OrderByList OrderBy
        {
            get { 
                if (orderBy == null)
                    orderBy = new OrderByList();
                return orderBy; 
            }
            set { orderBy = value; }
        }
        

        private GroupByList groupBy;
        public GroupByList GroupBy
        {
            get { 
                if (groupBy == null) 
                    groupBy = new GroupByList();
                return groupBy; 
            }
            set { groupBy = value; }
        }
        

        public int TopCount { get; set; }
        public Boolean Distinct { get; set; }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            sql.Append(indent);
            sql.Append("SELECT ");

            InternalBuildColumnList(sql, parameters, indent);

            InternalBuildFromClause(sql, parameters, indent);

            InternalBuildJoinClauses(sql, parameters, indent);

            InternalBuildWhereClause(sql, parameters, indent);

            InternalBuildGroupClause(sql, parameters, indent);

            InternalBuildHavingClause(sql, parameters, indent);

            InternalBuildOrderClause(sql, parameters, indent);
        }

        protected void InternalBuildColumnList(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (Distinct)
            {
                sql.Append("DISTINCT ");
            }
            if (TopCount > 0)
            {
                sql.Append("TOP ");
                sql.Append(TopCount);
                sql.Append(' ');
            }

            if ((columns != null) && (columns.Count() > 0))
            {
                Columns.BuildSQL(sql, parameters, indent);
                sql.Append(" \n");
                sql.Append(indent);
            }
            else
                sql.Append("* ");
        }

        protected void InternalBuildFromClause(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            sql.Append("FROM ");
            FromTable.BuildSQL(sql, parameters, indent);
        }


        protected void InternalBuildJoinClauses(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if ((joinTo != null) && (joinTo.Count() > 0))
            {
                JoinTo.BuildSQL(sql, parameters, indent);
            }
        }

        protected void InternalBuildWhereClause(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if ((where != null) && (where.Count() > 0))
            {
                sql.Append('\n');
                sql.Append(indent);
                sql.Append("WHERE ");
                where.BuildSQL(sql, parameters, indent);
            }

            if ((additionalConditions != null) && (additionalConditions.Count() > 0))
            {
                sql.Append('\n');
                sql.Append(indent);
                if ((where != null) && (where.Count() > 0))
                {
                    sql.Append(" AND ");
                }
                else
                {
                    sql.Append('\n');
                    sql.Append(indent);
                    sql.Append("WHERE ");
                }
                additionalConditions.BuildSQL(sql, parameters, indent);
            }
        }

        protected void InternalBuildGroupClause(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if ((groupBy != null) && (groupBy.Count() > 0))
            {
                sql.Append('\n');
                sql.Append(indent);
                sql.Append("GROUP BY ");
                groupBy.BuildSQL(sql, parameters, indent);
            }
        }

        protected void InternalBuildHavingClause(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if ((having != null) && (having.Count() > 0))
            {
                sql.Append('\n');
                sql.Append(indent);
                sql.Append("HAVING ");
                having.BuildSQL(sql, parameters, indent);
            }
        }

        protected void InternalBuildOrderClause(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if ((orderBy != null) && (orderBy.Count() > 0))
            {
                sql.Append('\n');
                sql.Append(indent);
                sql.Append("ORDER BY ");
                orderBy.BuildSQL(sql, parameters, indent);
            }
        }


    }

}
