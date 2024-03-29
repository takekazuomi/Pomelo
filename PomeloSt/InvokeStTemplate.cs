﻿using System.Collections;
using System.Linq;
using System.Management.Automation;
using System.Text;
using Antlr4.StringTemplate;
using Antlr4.StringTemplate.Visualizer.Extensions;

// http://www.powershellmagazine.com/2014/03/18/writing-a-powershell-module-in-c-part-1-the-basics/

// PSObject をstringtemplateから触れるようにするために。ObjectModelAdaptor が
// https://github.com/antlr/antlrcs/blob/master/Antlr4.StringTemplate/Misc/ObjectModelAdaptor.cs

namespace PomeloSt
{
    [Cmdlet(VerbsLifecycle.Invoke, "PoTemplate")]
    public class InvokeStTemplate : BaseStTemplate
    {
        [Parameter(HelpMessage = "show visualizer.")]
        public SwitchParameter Visualize { get; set; } = false;

        [Parameter(HelpMessage = "json mode.")]
        public SwitchParameter Json { get; set; } = false;

        protected override void BeginProcessing()
        {
            Template.Group.RegisterModelAdaptor(typeof(PSObject), new PSObjectModelAdaptor { WriteVerbose = WriteVerbose });
            if (Json)
                Template.Group.RegisterRenderer(typeof(string), new DefaultJsonRenderer());
            else
                Template.Group.RegisterRenderer(typeof(string), new JsonRenderer());
            //            _template.Group.RegisterRenderer(typeof(bool), new JsonRenderer());
        }

        protected override void ProcessRecord()
        {
            if (RuntimeDefinedParameterDictionary != null)
            {
                // The value specified by the dynamic parameter is used.
                // Others set what comes from the pipeline.
                foreach (var key in RuntimeDefinedParameterDictionary.Keys)
                {
                    var param = RuntimeDefinedParameterDictionary[key];
                    if (param.Value != null)
                    {
                        Dump("ProcessRecord: ", key, param.Value);
                        Template.Add(key, param.Value);
                    }
                }
            }
        }

        protected override void EndProcessing()
        {
            if (Visualize)
                Template.Visualize();
            else
            {
                WriteObject(Template.Render());
                foreach (var key in RuntimeDefinedParameterDictionary.Keys)
                {
                    var param = RuntimeDefinedParameterDictionary[key];
                    if (param.Value != null)
                        Template.Remove(key);
                }
            }
        }
        private void Dump(string message, string  key, object data)
        {
            if(!IsVerbose) 
                return;

            var e = data as IEnumerable;
            var sb= new StringBuilder();
            sb.AppendFormat("{0} Attribute:{1}, Type: ", message, key);
            sb.AppendLine(
                e != null ?
                string.Join(", ", e.Cast<object>().Select(o => o.GetType().Name)) : 
                data?.GetType().Name);
            WriteVerbose(sb.ToString().TrimEnd(',', ' '));
        }
    }
}
