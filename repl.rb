class Microsoft::Scripting::Silverlight::Repl
  IronRuby = 'silverlightDlrRepl1'
  Minimize = 'silverlightDlrWindowLink'
  
  def hide_all_panels
    window.eval("sdlrw.hideAllPanels(document.getElementById(\"#{Minimize}\"))")
  end
  
  def show_panel(id)
    window.eval("sdlrw.showPanel(\"#{id}\")")
  end
end

$repl = Microsoft::Scripting::Silverlight::Repl.show('ruby')
$stdout = $repl.output_buffer
$stderr = $repl.output_buffer
$repl.hide_all_panels

if document.query_string.contains_key 'console'
  $repl.show_panel(Microsoft::Scripting::Silverlight::Repl::IronRuby)
end