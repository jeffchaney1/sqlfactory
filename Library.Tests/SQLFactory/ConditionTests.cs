using Library.SQLFactory;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Tests.SQLFactory
{
    [TestClass]
    public class ConditionTests
    {
        [TestMethod]
        public void TestConditionIsMatch()
        {
            SimpleCondition condition = new SimpleCondition();
            condition.Expression = "Value > 20";

            Assert.IsTrue(condition.IsMatch("Value > 20"));
            Assert.IsTrue(condition.IsMatch("((value) >20"));
            Assert.IsTrue(condition.IsMatch("([VALUE] > (20))"));
            Assert.IsTrue(condition.IsMatch("Value"));
            Assert.IsFalse(condition.IsMatch("Value = 20"));
            Assert.IsFalse(condition.IsMatch("x"));

            condition.Expression = "value in ('one', 'two', 'three')";
            Assert.IsTrue(condition.IsMatch("value"));
            Assert.IsTrue(condition.IsMatch("value in ('one', 'two', 'three')"));

        }

        [TestMethod]
        public void TestSimpleCondition()
        {
            SimpleCondition condition = new SimpleCondition();
            condition.Expression = "value > 20";

            StringBuilder sql = new StringBuilder();
            condition.BuildSQL(sql, null);

            Assert.AreEqual("(value > 20)", sql.ToString());

            condition.Expression = "(Value = :)";
            condition.LiteralValue = "This is the value I'm looking for";

            sql = new StringBuilder();
            ParameterList parameterList = new ParameterList();
            condition.BuildSQL(sql, parameterList);

            Assert.AreEqual("(Value = 'This is the value I''m looking for') ", sql.ToString());
            Assert.AreEqual(0, parameterList.Count());

            condition.IsNegative = true;

            sql = new StringBuilder();
            condition.BuildSQL(sql, parameterList);

            Assert.AreEqual("(NOT (Value = 'This is the value I''m looking for') )", sql.ToString());
            Assert.AreEqual(0, parameterList.Count());

            condition = new SimpleCondition();
            condition.Expression = "(Value = :)";
            condition.Parameters.AddStringParameter("This is the value I'm looking for");
            sql = new StringBuilder();
            condition.BuildSQL(sql, parameterList);

            Assert.AreEqual("(Value = :) ", sql.ToString());
            Assert.AreEqual(1, parameterList.Count());
            // Should only be one single quote in the parameter value
            Assert.AreEqual("This is the value I'm looking for", parameterList.ElementAt(0).Value);


            condition.EmbedParameter = true;

            sql = new StringBuilder();
            parameterList = new ParameterList();
            condition.BuildSQL(sql, parameterList);

            Assert.AreEqual("(Value = 'This is the value I''m looking for') ", sql.ToString());
            Assert.AreEqual(0, parameterList.Count());

        }

        [TestMethod]
        public void TestSimpleConditionList()
        {
            ConditionList list = new ConditionList();
            StringBuilder sql = new StringBuilder();
            ParameterList parameterList = new ParameterList();

            list.Add("Field").LiteralValue = "one";
            list.BuildSQL(sql, parameterList);
            Assert.AreEqual("([Field] = 'one')", sql.ToString());
            Assert.AreEqual(0, parameterList.Count());

            list.Clear();
            sql.Clear();
            parameterList.Clear();

            list.Add("[Field]").LiteralValue = "two's";
            list.BuildSQL(sql, parameterList);
            Assert.AreEqual("([Field] = 'two''s')", sql.ToString());
            Assert.AreEqual(0, parameterList.Count());

            list.Clear();
            sql.Clear();
            parameterList.Clear();

            list.Add("Field > 20");
            list.BuildSQL(sql, parameterList);
            Assert.AreEqual("(Field > 20)", sql.ToString());
            Assert.AreEqual(0, parameterList.Count());

            list.Clear();
            sql.Clear();
            parameterList.Clear();

            list.Add("Field > : AND Field < :")
                    .AddIntegerParameter(20)
                    .AddIntegerParameter(30);
            list.BuildSQL(sql, parameterList);
            Assert.AreEqual("(Field > : AND Field < :)", sql.ToString());
            Assert.AreEqual(2, parameterList.Count());
            Assert.AreEqual(20, parameterList.ElementAt(0).Value);
            Assert.AreEqual(30, parameterList.ElementAt(1).Value);
        }

        [TestMethod]
        public void TestANDConditionList()
        {
            ConditionList list = new ConditionList();
            StringBuilder sql = new StringBuilder();
            ParameterList parameterList = new ParameterList();

            list.Add(new String[] { "Field1 = 20", "[Field2]", "Field3 = :" }
                , new Object[] { "two's", 30 });
            list.Add("[Field4] = :").AddStringParameter("Fourth Value");

            list.BuildSQL(sql, parameterList, "");
            Assert.AreEqual("(Field1 = 20)\nAND ([Field2] = 'two''s')\nAND (Field3 = 30)\nAND ([Field4] = :)", sql.ToString());
            Assert.AreEqual(1, parameterList.Count());
            Assert.AreEqual("Fourth Value", parameterList.ElementAt(0).Value);



        }
        [TestMethod]
        public void TestORConditionList()
        {
            ConditionList list = new ConditionList();
            list.DefaultLink = ConditionLinkOperator.loOR;

            StringBuilder sql = new StringBuilder();
            ParameterList parameterList = new ParameterList();

            list.Add(new String[] { "Field1 = 20", "[Field2]", "Field3 = :" }
                , new Object[] { "two's", 30 });
            list.Add("[Field4] = :").AddStringParameter("Fourth Value");

            list.BuildSQL(sql, parameterList, "");
            Assert.AreEqual("(Field1 = 20)\nOR ([Field2] = 'two''s')\nOR (Field3 = 30)\nOR ([Field4] = :)", sql.ToString());
            Assert.AreEqual(1, parameterList.Count());
            Assert.AreEqual("Fourth Value", parameterList.ElementAt(0).Value);



        }

        [TestMethod]
        public void TestINListCondition()
        {
            ConditionInList inList = new ConditionInList();
            inList.ValueExpression = "Field1";
            inList.AddValues(new String[] {
                "Value 1", "second Value", "Value 3"
            });

            StringBuilder sql = new StringBuilder();
            inList.BuildSQL(sql, null, "");

            Assert.AreEqual("(Field1 IN ('Value 1','second Value','Value 3') ) ", sql.ToString());


        }

        [TestMethod]
        public void TestComplexCondition()
        {
            ConditionList where = new ConditionList();
            where.Add("Field1").LiteralValue = "test value 1";

            ConditionGroup orGroup = where.AddGroup(ConditionLinkOperator.loOR);
            orGroup.Conditions.AddGroup(new String[] {
                "Field2 > 20", "Field3"
            }
            , new String[] { "third" }
            , ConditionLinkOperator.loAND);

            orGroup.Conditions.AddGroup(new String[] {
                "Field4", "Field5", "Field6"
            }
            , new Object[] { 20, new DateTime(2016, 10, 24), false }
            , ConditionLinkOperator.loAND);

            where.AddInList("Field7", new String[] {
                "one", "two", "three", "four"
            });

            StringBuilder sql = new StringBuilder();
            where.BuildSQL(sql, null, "");

            Assert.AreEqual("([Field1] = 'test value 1')\n" +
                            "AND (" + 
                                   "("  +
                                        "(Field2 > 20)\n" +
                                    "AND ([Field3] = 'third')" +
                                   ")\n" +
                                 "OR (" +
                                        "([Field4] = 20)\n" +
                                    "AND ([Field5] = '2016-10-24')\n" +
                                    "AND ([Field6] = 0/*False*/)" +
                                    ")" +
                                 ")\n" +
                            "AND (Field7 IN ('one','two','three','four') ) "
                            , sql.ToString());
        }
    }
}
