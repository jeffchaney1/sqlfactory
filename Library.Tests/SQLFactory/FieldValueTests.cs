using Library.SQLFactory;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Tests.SQLFactory
{
    [TestClass]
    public class FieldValueTests
    {
        [TestMethod]
        public void TestStringField()
        {
            FieldValue field = new FieldValue();

            field.ColumnName = "Column1";
            field.LiteralValue = "This is a test Value";

            Assert.AreEqual("[Column1]", field.BuildSQL(null));
            
            StringBuilder buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual("'This is a test Value'", buf.ToString());

            field.LiteralValue = "This is a test Value, 'testvalue'.";
            buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual("'This is a test Value, ''testvalue''.'", buf.ToString());

            field.LiteralValue = "This is a test Value, '\u2342'.";
            buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual("N'This is a test Value, ''\u2342''.'", buf.ToString());
        }

        [TestMethod]
        public void TestNumericField()
        {
            FieldValue field = new FieldValue();

            field.ColumnName = "Column1";
            field.LiteralValue = 25;

            Assert.AreEqual("[Column1]", field.BuildSQL(null));

            StringBuilder buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual("25", buf.ToString());

            field.LiteralValue = 2343234.453345;
            buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual("2343234.453345", buf.ToString());

            field.LiteralValue = 2343234.453345;
            CultureInfo saveCulture = System.Threading.Thread.CurrentThread.CurrentUICulture;
            try {
                CultureInfo newCulture = CultureInfo.GetCultureInfo("pt-BR");
                Assert.AreEqual(",", newCulture.NumberFormat.NumberDecimalSeparator);
                // By changing to Brazil the decimal separator will be a comma
                System.Threading.Thread.CurrentThread.CurrentCulture = newCulture;
                // This just makes sure I set the culture correctly to get the comma under normal circumstances.
                Assert.AreEqual("2343234,453345", field.LiteralValue.ToString());

                //  For SQL we don't want the comma we always want a period, so this is the
                //   real test.  The FieldValue should only return a period.
                buf = new StringBuilder();
                field.BuildValue(buf, null);
                Assert.AreEqual("2343234.453345", buf.ToString());
            }
            finally {
                System.Threading.Thread.CurrentThread.CurrentUICulture = saveCulture;

            }
        }

        [TestMethod]
        public void TestBooleanField()
        {
            FieldValue field = new FieldValue();

            field.ColumnName = "Column1";
            field.LiteralValue = true;

            Assert.AreEqual("[Column1]", field.BuildSQL(null));

            StringBuilder buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual("1/*True*/", buf.ToString());

            field.LiteralValue = false;
            buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual("0/*False*/", buf.ToString());
        }

        private DateTime buildDate(int year, int month, int day, int hour, int min, int sec, int millisec, TimeZoneInfo tz)
        {
            //hour
            day += tz.BaseUtcOffset.Days;
            hour += tz.BaseUtcOffset.Hours;
            min += tz.BaseUtcOffset.Minutes;
            sec += tz.BaseUtcOffset.Seconds;
            millisec += tz.BaseUtcOffset.Milliseconds;

            DateTime result = new DateTime(year, month, day, hour, min, sec, millisec);
            //TimeZoneInfo.ConvertTimeFromUtc()
            return result;
        }

        private void testFieldValue(int yr, int mo, int dy, int hr, int mi, int se, int ms, DateTimeKind kind)
        {
            FieldValue field = new FieldValue();

            DateTime dt = new DateTime(yr, mo, dy, hr, mi, se, ms, kind);
            String expectedNormal;
            if ((hr == 0) && (mi == 0))
                expectedNormal = String.Format("'{0:yyyy-MM-dd}'", dt);
            else
                expectedNormal = String.Format("'{0:yyyy-MM-dd HH:mm:ss.FFF}'", dt);

            String expectedUTC = String.Format("'{0:yyyy-MM-ddTHH:mm:sszzz}'", dt);

            field.LiteralValue = dt;
            field.OutputUTC = false;

            StringBuilder buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual(expectedNormal, buf.ToString(), kind.ToString() + 
                ", Date is " + (dt.IsDaylightSavingTime() ? "" : "NOT ") + "in DST" + 
                ", OutputUseUTC = false");

            field.OutputUTC = true;
            buf = new StringBuilder();
            field.BuildValue(buf, null);
            Assert.AreEqual(expectedUTC, buf.ToString(), kind.ToString() +
                ", Date is " + (dt.IsDaylightSavingTime() ? "" : "NOT ") + "in DST" +
                ", OutputUseUTC = true");
        }

        [TestMethod]
        public void TestDateTimeField()
        {
            //TimeZoneInfo.Local.current
            FieldValue field = new FieldValue();

            field.ColumnName = "Column1";
            DateTime dt = new DateTime(2016, 6, 20, 10, 53, 18, 087, DateTimeKind.Local);
            field.LiteralValue = dt;
            field.OutputUTC = false;

            Assert.AreEqual("[Column1]", field.BuildSQL(null));

            testFieldValue(2016, 6, 20, 10, 53, 18, 087, DateTimeKind.Local);

            testFieldValue(2016, 1, 20, 10, 53, 18, 087, DateTimeKind.Local);

            //testFieldValue(2016, 6, 20, 10, 53, 18, 087, DateTimeKind.Utc);
            //testFieldValue(2016, 1, 20, 10, 53, 18, 087, DateTimeKind.Utc);

            testFieldValue(2016, 1, 20, 0, 0, 0, 0, DateTimeKind.Local);
            testFieldValue(2016, 6, 20, 0, 0, 0, 0, DateTimeKind.Local);
            //testFieldValue(2016, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc);
            //testFieldValue(2016, 6, 20, 0, 0, 0, 0, DateTimeKind.Utc);


        }
        [TestMethod]
        public void TestFieldValueList()
        {
            FieldValueList colList = new FieldValueList();
            colList.Add("StringValue", 
                "This is my test String Value that is slightly too long")
                .MaxLength = 30;
            

            colList.Add("ShortString", "Test Value");

            colList.Add("FloatValue", 123.456);

            colList.Add("IntegerValue",123456);

            colList.Add("BooleanValue", true);

            colList.Insert(3, "FalseValue",false);

            colList.Add("DateValue",new DateTime(2016, 10, 24));

            colList.Add("DateTimeValue", new DateTime(2016, 1, 15, 13, 24, 56, 789));

            colList.Add("ParameterValue")
                .Parameters.AddStringParameter("This is parameter 1");
            
            colList.Add("RawValue", "raw value")
                .UseRaw = true;

            colList.Add("NULLValue",null);

            StringBuilder buf = new StringBuilder();
            ParameterList parameterList = new ParameterList();
            colList.ColumnsPerRow = 20;

            colList.BuildSQL(buf, parameterList, "");
            Assert.AreEqual("[StringValue], [ShortString], [FloatValue], [FalseValue], " +
                            "[IntegerValue], [BooleanValue], [DateValue], [DateTimeValue], " +
                            "[ParameterValue], [RawValue], [NULLValue]", buf.ToString());
            Assert.AreEqual(0, parameterList.Count(), "ParameterList.Count");

            buf = new StringBuilder();
            colList.BuildValuesList(buf, parameterList, "");

            Assert.AreEqual("VALUES (" + 
                            "'This is my test String Value t', " +
                            "'Test Value', " +
                            "123.456, " +
                            "0/*False*/, " +
                            "123456, " +
                            "1/*True*/, " +
                            "'2016-10-24', '2016-01-15 13:24:56.789', " +
                            ":, raw value, NULL)", buf.ToString());
            Assert.AreEqual(1, parameterList.Count(), "ParameterList.Count");

            Assert.AreEqual("This is parameter 1", parameterList.ElementAt(0).Value.ToString());
            Assert.AreEqual(DataType.dtString, parameterList.ElementAt(0).Type);
            Assert.AreEqual(ParameterDirection.pdInput, parameterList.ElementAt(0).Direction);

            
        }
    }


}
