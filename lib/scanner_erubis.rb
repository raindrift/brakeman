begin
  require 'erubis'
rescue LoadError => e
  $stderr.puts e.message
  $stderr.puts "Please install Erubis."
  exit!
end

#This is from Rails 3 version of the Erubis handler
class RailsXSSErubis < ::Erubis::Eruby
  include Erubis::NoTextEnhancer

  #Initializes output buffer.
  def add_preamble(src)
    # src << "_buf = ActionView::SafeBuffer.new;\n"
  end

  #This does nothing.
  def add_text(src, text)
    # src << "@output_buffer << ('" << escape_text(text) << "'.html_safe!);"
  end

  BLOCK_EXPR = /\s+(do|\{)(\s*\|[^|]*\|)?\s*\Z/

  def add_expr_literal(src, code)
    if code =~ BLOCK_EXPR
      src << '@output_buffer.append= ' << code
    else
      src << '@output_buffer.append= (' << code << ');'
    end
  end

  def add_stmt(src, code)
    if code =~ BLOCK_EXPR
      src << '@output_buffer.append_if_string= ' << code
    else
      super
    end
  end

  def add_expr_escaped(src, code)
    if code =~ BLOCK_EXPR
      src << "@output_buffer.safe_append= " << code
    else
      src << "@output_buffer.safe_concat(" << code << ");"
    end
  end

  #Add code to output buffer.
  def add_postamble(src)
    # src << '_buf.to_s'
  end
end

#Erubis processor which ignores any output which is plain text.
class ScannerErubis < Erubis::Eruby
  include Erubis::NoTextEnhancer
end

class ErubisEscape < ScannerErubis
  include Erubis::EscapeEnhancer
end
