class OX.ConfirmationPopover

  constructor: (options) ->
    @options = _.defaults({}, options, {
      html: true,
      title: 'confirmation-popover-title'
      placement: 'right'
      cancelText: 'confirmation-popover-cancelText'
      confirmText: 'confirmation-popover-confirmText'
      message: 'confirmation-popover-message'
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
    """
      <div>
        <span class="message" data-l10n-id="#{@options.message}"></span>
        <p class="button-group" style="margin-top: 10px; text-align: center;">
          <button type="button" class="btn btn-small confirm-dialog-btn-abort" data-l10n-id="#{@options.cancelText}"></button>
          <button type="button" class="btn btn-small btn-danger confirm-dialog-btn-confirm" data-l10n-id="#{@options.confirmText}"></button>
        </p>
      </div>
    """
