using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Web.UI.WebControls;
using Antlr4.StringTemplate;

// http://www.powershellmagazine.com/2014/03/18/writing-a-powershell-module-in-c-part-1-the-basics/

// PSObject をstringtemplateから触れるようにするために。ObjectModelAdaptor が
// https://github.com/antlr/antlrcs/blob/master/Antlr4.StringTemplate/Misc/ObjectModelAdaptor.cs

namespace PomeloSt
{
    public abstract  class BaseStTemplate : PSCmdlet, IDynamicParameters
    {
        [Parameter(ParameterSetName = "anonymous", HelpMessage = "template string", Mandatory = true, Position = 0)]
        public string TemplateString { get; set; }

        [Parameter(ParameterSetName = "anonymous", HelpMessage = "template properties name", Mandatory = true, Position = 1)]
        public string[] Properties { get; set; }

        [Parameter(ParameterSetName = "group", HelpMessage = "template group directory or group file", Mandatory = true, Position = 0)]
        public string GroupPath { get; set; }

        [Parameter(ParameterSetName = "groupstring", HelpMessage = "template group string", Mandatory = true, Position = 0)]
        public string GroupString { get; set; }

        [Parameter(ParameterSetName = "group", HelpMessage = "template name", Mandatory = true, Position = 0)]
        [Parameter(ParameterSetName = "groupstring")]
        public string TemplateName { get; set; }

        [Parameter(HelpMessage = "delimiter start char, default: <")]
        public char DelimiterStartChar { get; set; } = '<';

        [Parameter(HelpMessage = "delimiter end char, default: >")]
        public char DelimiterStopChar { get; set; } = '>';


        protected Template Template;
        protected RuntimeDefinedParameterDictionary RuntimeDefinedParameterDictionary;

        protected bool IsVerbose;

        private void PrepareTemplate()
        {
            TemplateGroup templateGroup;
            switch (ParameterSetName)
            {
                case "group":
                    var path = System.IO.Path.GetFullPath(GroupPath);
                    if (path.EndsWith(TemplateGroup.GroupFileExtension, StringComparison.InvariantCultureIgnoreCase))
                        templateGroup = new TemplateGroupFile(path, Encoding.UTF8, DelimiterStartChar, DelimiterStopChar)
                        {
                            Verbose = IsVerbose,
                            Logger = Host.UI.WriteVerboseLine
                        };
                    else
                        templateGroup = new TemplateGroupDirectory(path, Encoding.UTF8, DelimiterStartChar, DelimiterStopChar)
                        {
                            Verbose = IsVerbose,
                            Logger = Host.UI.WriteVerboseLine
                        };
                    Template = templateGroup.GetInstanceOf(TemplateName);
                    break;
                case "groupstring":
                    templateGroup = new TemplateGroupString(TemplateName, GroupString, DelimiterStartChar, DelimiterStopChar);
                    Template = templateGroup.GetInstanceOf(TemplateName);
                    break;
                case "anonymous":
                    Template = new Template(TemplateString, DelimiterStartChar, DelimiterStopChar);
                    break;
            }
        }

        ICollection<string> GetAttributes()
        {
            var attr = Template?.GetAttributes();
            if (attr != null)
                return attr.Keys;
            return Properties;
        }

        public virtual  object GetDynamicParameters()
        {
            IsVerbose = MyInvocation.BoundParameters.ContainsKey("Verbose") &&
                        ((SwitchParameter) MyInvocation.BoundParameters["Verbose"]).ToBool();
            try
            {
                PrepareTemplate();

                var paramDictionary = new RuntimeDefinedParameterDictionary();
                var keys = GetAttributes();
                if (keys != null)
                {
                    if (IsVerbose)
                    {
                        var m = string.Format("top level attributes: {0}", string.Join(", ", keys));
                        Host.UI.WriteVerboseLine(m);
                    }
                    foreach (var key in keys)
                    {
                        var attribute = new ParameterAttribute
                        {
                            ValueFromPipeline = true,
                            ValueFromPipelineByPropertyName = true
                        };
                        var attributeCollection = new Collection<System.Attribute> {attribute};
                        var param = new RuntimeDefinedParameter(key, typeof(object), attributeCollection);
                        paramDictionary.Add(key, param);
                    }
                    RuntimeDefinedParameterDictionary = paramDictionary;
                }
                else
                    Host.UI.WriteWarningLine("no formal argument");

                return paramDictionary;
            }
            catch (Exception e)
            {
                var m = string.Format("In GetDynamicParameters: {0}", e);
                if (IsVerbose)
                    Host.UI.WriteVerboseLine(m);
                throw;
            }
        }
    }
}
