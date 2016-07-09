using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Library.Enum;

namespace Library.Tests.Enum
{
    public class TestingEnum : EnumImpl<TestingEnum>
    {
        private TestingEnum(String name, int? ordinal = null, String code = null)
            : base(name, ordinal, code) { }

        public static readonly TestingEnum teOne = new TestingEnum("One");
        public static readonly TestingEnum teTwo = new TestingEnum("Two");
        public static readonly TestingEnum teThree = new TestingEnum("Three", 30);
        public static readonly TestingEnum teFour = new TestingEnum("Four");

    }

    [TestClass]
    public class EnumTests : EnumImpl<EnumTests>
    {
        public EnumTests() { }

        private EnumTests(String name, int? ordinal = null, String code = null)
            : base(name, ordinal, code) { }

        public static readonly EnumTests teOne = new EnumTests("One");
        public static readonly EnumTests teTwo = new EnumTests("Two");
        public static readonly EnumTests teThree = new EnumTests("Three", 30);
        public static readonly EnumTests teFour = new EnumTests("Four");


        [TestMethod]
        public void TestEnumerationClassInitialization()
        {
            // I don't know why this is allowed when EnumImpl can't access protected members of EnumBase
            //new TestingEnum("test");
            EnumTests.Seal();

            EnumTests value;

            Assert.AreEqual("One", EnumTests.teOne.Name);
            Assert.AreEqual(0, EnumTests.teOne.Ordinal);

            Assert.AreEqual("Three", EnumTests.teThree.Name);
            Assert.AreEqual(30, EnumTests.teThree.Ordinal);

            Assert.AreEqual("Four", EnumTests.teFour.Name);
            Assert.AreEqual(31, EnumTests.teFour.Ordinal);
        }

        [TestMethod]
        public void TestEnumerationClassLookup()
        {
            EnumTests.Seal();
            EnumTests value;

            Assert.AreEqual(1, EnumTests.FromName("two").Ordinal);

            Assert.IsTrue(EnumTests.TryFromName("Four", out value));
            Assert.AreEqual("Four", value.Name);

            Assert.IsFalse(EnumTests.TryFromName("Not Found", out value));

            Assert.IsTrue(EnumTests.TryFromOrdinal(0, out value));
        }

        [TestMethod]
        public void TestEnumerationClassEquals()
        {
            EnumerationValue value = EnumTests.teFour;

            Assert.IsTrue(value.Equals(EnumTests.teFour), "expected " + EnumTests.teFour + " but found " + value);
            Assert.IsTrue(value.Equals("four"));
            Assert.IsTrue(value.Equals(31));

            Assert.IsFalse(value.Equals(EnumTests.teThree));
            Assert.IsFalse(value.Equals("three"));
            Assert.IsFalse(value.Equals(1));
            Assert.IsFalse(value.Equals(12.1));
            Assert.IsTrue(value.Equals(30.8));

            value = EnumTests.teOne;
            Assert.AreEqual(0, value.Ordinal);

            Assert.IsTrue(value.Equals(EnumTests.teOne));
            Assert.IsTrue(value.Equals("ONE"));
            Assert.IsTrue(value.Equals(0));

            Assert.IsFalse(value.Equals(EnumTests.teThree));
            Assert.IsFalse(value.Equals("two"));
            Assert.IsFalse(value.Equals(-1));

        }

        [TestMethod]
        [ExpectedException(typeof(EnumerationException))]
        public void TestDuplicateCode()
        {
            EnumTests four = new EnumTests("Four");
        }

        [TestMethod]
        [ExpectedException(typeof(EnumerationException))]
        public void TestDuplicateOrdinal()
        {
            EnumTests five = new EnumTests("Five", 1);
        }
    }

}
