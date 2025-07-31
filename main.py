# main.py
from detector import classify_jailbreak

def run_single_detection(
    prompt: str,
    response: str,
    hf_threshold=0.42,
    rejection_threshold=0.7,
    hf_weight=0.5,
    rejection_weight=0.5,
    fusion_threshold=0.8
):
    """
    Run jailbreak detection on a single prompt/response pair.
    """
    prediction = classify_jailbreak(
        prompt=prompt,
        response=response,
        hf_threshold=hf_threshold,
        rejection_threshold=rejection_threshold,
        hf_weight=hf_weight,
        rejection_weight=rejection_weight,
        final_threshold=fusion_threshold
    )

    print(f"\n🧾 Final Prediction: {prediction}")
    return prediction


if __name__ == "__main__":
    # Example usage with manual input
    print("🔍 Jailbreak Detection - Single Input Mode")
    prompt_input = input("\n✏️ Enter Prompt: ")
    response_input = input("🤖 Enter LLM Response: ")

    run_single_detection(
        prompt=prompt_input,
        response=response_input
    )
