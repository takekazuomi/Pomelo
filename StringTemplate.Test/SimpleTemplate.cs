using System;
using System.Collections;
using System.Collections.Generic;
using Antlr4.StringTemplate;
using Xunit;

namespace StringTemplate.Test
{
    public class SimpleTemplate
    {
        static void DumpIDictionary(string name, IDictionary<string, object> dic)
        {
            if (dic == null)
                Console.WriteLine("{0}: null", name);
            else
                foreach (var key in dic.Keys)
                    Console.WriteLine("{0}: {1} -> {2}", name, key, dic[key]);
        }

//        [Fact]
        public void WithoutFormalArgument()
        {
            var template = new Template("<name>", '<', '>');
            Console.WriteLine("template.Name: {0}", template.Name);
            Console.WriteLine("IsAnonymousSubtemplate: {0}", template.IsAnonymousSubtemplate);
            var attrs = template.GetAttributes();
            DumpIDictionary("GetAttributes", attrs);

            Console.WriteLine("GetAttribute(\"name\"): {0}", template.GetAttribute("name"));
            template.Add("name", "Hello world");
            Console.WriteLine("GetAttribute(\"name\"): {0}", template.GetAttribute("name"));
            template.Add("namex", "Hello world");
            Console.WriteLine(template.Render());

            //template.impl.
        }

        [Fact]
        public void SimpleFormalArgument()
        {
            var decl = @"decl(type, name) ::= ""<type> <name>;""";
            var template = new Template(decl, '<', '>');
            Console.WriteLine("template.Name: {0}", template.Name);
            Console.WriteLine("IsAnonymousSubtemplate: {0}", template.IsAnonymousSubtemplate);
            var attrs = template.GetAttributes();
            DumpIDictionary("GetAttributes", attrs);
        }

        [Fact]
        public void TemplateGroupFormalArgument()
        {
            var decl = @"decl(type, name) ::= ""<type> <name>;""";
            var templateGroup = new TemplateGroupString("decl", decl, '<', '>');

            var template = templateGroup.GetInstanceOf("decl");
            Console.WriteLine("template.Name: {0}", template.Name);
            Console.WriteLine("IsAnonymousSubtemplate: {0}", template.IsAnonymousSubtemplate);
            var attrs = template.GetAttributes();
            DumpIDictionary("GetAttributes", attrs);
        }
    }
}
