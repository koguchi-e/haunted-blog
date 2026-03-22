# frozen_string_literal: true

module BlogsHelper
  def format_content(blog)
    sanitize(blog.content).gsub("\n", '<br>').html_safe # rubocop:disable Rails/OutputSafety
  end
end
