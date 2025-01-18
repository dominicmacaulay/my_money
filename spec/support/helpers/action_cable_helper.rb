# frozen_string_literal: true

module ActionCableHelper
  def wait_for_stream_connection
    expect(page).to have_css('turbo-cable-stream-source[connected]', visible: :hidden)
  end
end
