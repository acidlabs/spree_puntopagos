module Spree
  CheckoutHelper.class_eval do
    alias_method :orig_checkout_progress, :checkout_progress

    def checkout_progress_with_puntopagos order
      states = order.checkout_steps
      items = states.map do |state|
        text = Spree.t("order_state.#{state}").titleize

        css_classes = []

        current_index          = states.index(order.state)
        state_index            = states.index(state)

        css_classes << 'next'    if state_index == current_index + 1
        css_classes << 'current' if state == order.state
        css_classes << 'first'   if state_index == 0
        css_classes << 'last'    if state_index == states.length - 1
        # It'd be nice to have separate classes but combining them with a dash helps out for IE6 which only sees the last class
        content_tag('li', content_tag('span', text), class: css_classes.join('-'))
      end
      content_tag('ol', raw(items.join("\n")), class: 'progress-steps', id: "checkout-step-#{order.state}")
    end
  end
end