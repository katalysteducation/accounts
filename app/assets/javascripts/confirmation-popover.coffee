class OX.ConfirmationPopover

  constructor: (options) ->
    @options = _.defaults({}, options, {
      html: true,
      placement: 'right'
      cancelText: window.confirmationPopoverDefaultCancelText || 'Cancel'
      confirmText: window.confirmationPopoverDefaultConfirmText || 'OK'
      message: ''
    })
    # call after defaults are set since generateContent reads @options
    @options.content = $(@generateContent())
    popover = $(@options.target).popover(@options)
    popover.popover('show')
    @options.content.on('click', '.btn', (ev) ->
      popover.popover('destroy')
      isAbort = $(this).hasClass('confirm-dialog-btn-abort')
      cb = if isAbort then options.onCancel else options.onConfirm
      cb(ev) if cb
    )

  generateContent: ->
    message = @options.target.dataset.message || @options.message
    cancelText = @options.target.dataset.canceltext || @options.cancelText
    confirmText = @options.target.dataset.confirmtext || @options.confirmText
    """
      <div>
        <span class="message">#{message}</span>
        <p class="button-group" style="margin-top: 10px; text-align: center;">
          <button type="button" class="btn btn-small confirm-dialog-btn-abort">#{cancelText}</button>
          <button type="button" class="btn btn-small btn-danger confirm-dialog-btn-confirm">#{confirmText}</button>
        </p>
      </div>
    """
