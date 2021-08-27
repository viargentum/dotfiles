function fish_user_key_bindings
  fzf_key_bindings

  bind --erase --key \ek
  bind --erase --key \ej
  bind --erase --preset \el

  bind \el exa --long --icons
end
