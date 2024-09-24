{

  programs.zsh = {
    initExtra = ''
      klogs-sandbox () {
        pod = "$(kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox -n sandbox get po -o wide|tail -n+2|fzf -n1 --reverse --tac --preview='kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox -n sandbox logs --tail=20 --all-containers=true {1} |jq' --preview-window=down:50%:hidden --bind=ctrl-p:toggle-preview --header="^P: Preview Logs "|awk '{print $1}' | jq)"
          if [[ -n $pod ]];
          then
            kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox logs --all-containers = true $pod
          fi
      }
    '';
  };
}
